//
//  RMMKVFile.m
//  remuxer
//
//  Created by Evan Coleman on 2/16/14.
//  Copyright (c) 2014 Evan Coleman. All rights reserved.
//

#import "RMMKVFile.h"
#import "ECTask.h"

@implementation RMMKVFile

#pragma mark - RMFile

- (NSString *)container {
    return @"mkv";
}

- (NSArray *)readFileTracks {
    ECTask *task = [[ECTask alloc] initWithLaunchPath:[self mkvinfoPath]];
    task.arguments = @[self.path];
    [task launch];
    [task waitUntilExit];

    CGFloat duration = [[self findItemWithRegex:@"(?<=Duration: ).[^s]*" inString:task.output] doubleValue];
    NSArray *split = [task.output componentsSeparatedByString:@"|+"];
    NSString *tracksString = nil;
    for (NSString *s in split) {
        if ([s rangeOfString:@"Segment tracks"].location != NSNotFound) {
            tracksString = s;
            break;
        }
    }
    NSArray *tracksSplit = [tracksString componentsSeparatedByString:@"| + A track"];
    NSMutableArray *tracks = [[NSMutableArray alloc] init];
    for (int i=1;i<[tracksSplit count];i++) {
        NSString *trackString = tracksSplit[i];
        NSString *type = [self findItemWithRegex:@"(?<=Track type: ).*" inString:trackString];
        if ([type isEqualToString:@"video"]) {
            RMVideoTrack *track = [[RMVideoTrack alloc] init];
            [track setCodecString:[self findItemWithRegex:@"(?<=Codec ID: ).*" inString:trackString]];
            track.duration = duration;
            track.resolution = CGSizeMake([[self findItemWithRegex:@"(?<=Display width: ).*" inString:trackString] integerValue],
                                          [[self findItemWithRegex:@"(?<=Display height: ).*" inString:trackString] integerValue]);
            [tracks addObject:track];
        } else if ([type isEqualToString:@"audio"]) {
            RMAudioTrack *track = [[RMAudioTrack alloc] init];
            [track setCodecString:[self findItemWithRegex:@"(?<=Codec ID: ).*" inString:trackString]];
            track.duration = duration;
            track.sampleRate = [[self findItemWithRegex:@"(?<=Sampling frequency: ).*" inString:trackString] doubleValue];
            [tracks addObject:track];
        } else if ([type isEqualToString:@"subtitles"]) {
            RMSubtitleTrack *track = [[RMSubtitleTrack alloc] init];
            [track setCodecString:[self findItemWithRegex:@"(?<=Codec ID: ).*" inString:trackString]];
            [tracks addObject:track];
        }
    }

    _tracks = [tracks copy];
    return _tracks;
}

- (NSString *)mkvinfoPath {
    return @"/usr/local/bin/mkvinfo";
}

- (NSString *)findItemWithRegex:(NSString *)regexString inString:(NSString *)string {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:0 error:nil];
    NSArray *textCheckingResults = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    
    for (NSTextCheckingResult *result in textCheckingResults) {
        NSRange matchRange = [result rangeAtIndex:0];
        NSString *match = [string substringWithRange:matchRange];
        return match;
    }
    
    return nil;
}

@end
