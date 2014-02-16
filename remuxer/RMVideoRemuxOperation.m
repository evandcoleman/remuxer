//
//  RMVideoRemuxer.m
//  remuxer
//
//  Created by Evan Coleman on 2/16/14.
//  Copyright (c) 2014 Evan Coleman. All rights reserved.
//

#import "RMVideoRemuxOperation.h"
#import "RMRemuxerController.h"
#import "ColorMacros.h"
#import "ECTask.h"
#import "RMMP4File.h"
#import "RMMKVFile.h"

@interface RMVideoRemuxOperation () {
    BOOL _finished;
}

@property (nonatomic) RMFile *file;
@property (nonatomic, readonly) NSString *inputPath;
@property (nonatomic, readonly) NSString *outputDirectory;

@end

@implementation RMVideoRemuxOperation

- (instancetype)initWithFile:(RMFile *)file {
    self = [super init];
    if (self) {
        _file = file;
    }
    return self;
}

#pragma mark - NSOperation

- (void)main {
    @autoreleasepool {
        if (self.isCancelled) {
            return;
        }
        
        if (!self.file) {
            [self completeOperation];
            return;
        }
        
        
        NSString *path = self.file.path;
        NSString *outPath = [self.outputDirectory stringByAppendingPathComponent:[[[path lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"m4v"]];
        if (!outPath) {
            outPath = [[path stringByDeletingPathExtension] stringByAppendingPathExtension:@"m4v"];
        }
        fprintf(stderr, BOLDBLUE "Processing file:" RESET " %s\n", [path UTF8String]);
        
        // Get file codecs
        NSArray *trackCodecs = [self.file readFileTracks];
        if (!trackCodecs) {
            fprintf(stderr, BOLDRED "Container format %s is not supported.\n" RESET, [[path pathExtension] UTF8String]);
            [self completeOperation];
            return;
        } else if ([trackCodecs count] == 0) {
            fprintf(stderr, BOLDRED "No media tracks found. Are you sure this is a video file?\n" RESET);
            [self completeOperation];
            return;
        } else {
            fprintf(stderr, BOLDBLUE "%lu tracks found:" RESET "\n", [trackCodecs count]);
            for (NSString *t in trackCodecs) {
                fprintf(stderr, "\t%s\n", [[t description] UTF8String]);
            }
        }
        
        // Setup the ffmpeg task
        RMVideoTrack *videoTrack = [self.file firstVideoTrack];
        CGFloat duration = videoTrack.duration;
        NSUInteger videoTrackIndex = [self.file indexOfFirstVideoTrack];
        NSUInteger ac3TrackIndex = [self.file indexOfFirstAudioTrack];
        
        NSArray *arguments = @[@"-i", path,
                               @"-map", [NSString stringWithFormat:@"0:%li", videoTrackIndex],
                               @"-map", [NSString stringWithFormat:@"0:%li", ac3TrackIndex],
                               @"-map", [NSString stringWithFormat:@"0:%li", ac3TrackIndex],
                               @"-c:v", @"copy",
                               @"-c:a:0", @"aac",
                               @"-ab", @"160k",
                               @"-ac", @"2",
                               @"-c:a:1", @"copy",
                               @"-strict", @"experimental",
                               @"-f", @"mp4",
                               outPath];
        
        fprintf(stderr, "Mapping video track %li to 0\n", videoTrackIndex);
        fprintf(stderr, "Mapping AAC track %li to 1\n", ac3TrackIndex);
        fprintf(stderr, "Mapping AC3 track %li to 2\n", ac3TrackIndex);
        
//        if ([self subtitleTrackNumber:trackCodecs]) {
//            fprintf(stderr, BOLDRED "Skipping subtitles.\n" RESET);
//            [self completeOperation];
//            return;
//        }
        
        __block BOOL isDone = NO;
        ECTask *task = [[ECTask alloc] initWithLaunchPath:[self ffmpegPath]];
        task.arguments = arguments;
        task.outputBlock = ^(NSString *output) {
            if (isDone) return;
            if ([output rangeOfString:@"muxing overhead"].location == NSNotFound) {
                CGFloat time = [self timeWithString:output];
                int prog = (time / duration) * 100;
                if (prog < 25) {
                    fprintf(stderr, BOLDMAGENTA "\rRemuxing: " BOLDRED "%d%c" RESET, prog, '%');
                } else if (prog >= 25 && prog < 50) {
                    fprintf(stderr, BOLDMAGENTA "\rRemuxing: " BOLDYELLOW "%d%c" RESET, prog, '%');
                } else if (prog >= 50 && prog < 75) {
                    fprintf(stderr, BOLDMAGENTA "\rRemuxing: " BOLDCYAN "%d%c" RESET, prog, '%');
                } else if (prog >= 75 && prog < 100) {
                    fprintf(stderr, BOLDMAGENTA "\rRemuxing: " BOLDBLUE "%d%c" RESET, prog, '%');
                }
            } else {
                // Done
                isDone = YES;
                fprintf(stderr, BOLDMAGENTA "\rRemuxing: " BOLDGREEN "%d%c\n" RESET, 100, '%');
                [self completeOperation];
            }
        };
        [task launch];
        [task waitUntilExit];
    }
}

- (void)completeOperation {
    [self willChangeValueForKey:@"isFinished"];
    
    _finished = YES;
    
    [self didChangeValueForKey:@"isFinished"];
}

- (BOOL)isFinished {
    return _finished;
}

#pragma mark - Helpers

- (NSString *)inputPath {
    return [[RMRemuxerController sharedInstance] inputPath];
}

- (NSString *)outputDirectory {
    return [[RMRemuxerController sharedInstance] outputDirectory];
}

- (NSString *)ffmpegPath {
    return @"/usr/local/bin/ffmpeg";
}

- (CGFloat)timeWithString:(NSString *)string {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(?<=time=)(.*)(?= )" options:0 error:nil];
    NSArray *textCheckingResults = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    
    NSRange matchRange = [[textCheckingResults lastObject] rangeAtIndex:1];
    NSString *match = [string substringWithRange:matchRange];
    NSArray *times = [[[match componentsSeparatedByString:@" "] firstObject]  componentsSeparatedByString:@":"];
    
    if ([times count] < 3) {
        return 0.0;
    }
    
    CGFloat retVal = 0.0;
    retVal += [[times objectAtIndex:0] doubleValue] * 60 * 60;
    retVal += [[times objectAtIndex:1] doubleValue] * 60;
    retVal += [[times objectAtIndex:2] doubleValue];
    
    return retVal;
}

@end
