//
//  RMMP4File.m
//  remuxer
//
//  Created by Evan Coleman on 2/16/14.
//  Copyright (c) 2014 Evan Coleman. All rights reserved.
//

#import "RMMP4File.h"
#import "ECTask.h"

@implementation RMMP4File

#pragma mark - RMFile

- (NSArray *)readFileTracks {
    ECTask *task = [[ECTask alloc] initWithLaunchPath:[self mp4infoPath]];
    task.arguments = @[self.path];
    [task launch];
    [task waitUntilExit];
    NSArray *arr = [task.output componentsSeparatedByString:@"\n"];
    
    NSMutableArray *tracks = [NSMutableArray array];
    for (NSString *str in arr) {
        if (str.length > 0) {
            NSString *c = [str substringToIndex:1];
            NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
            NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:c];
            BOOL valid = [alphaNums isSupersetOfSet:inStringSet];
            
            if (valid) {
                NSArray *arr = [str componentsSeparatedByString:@" "];
                NSArray *lineOne = [arr[0] componentsSeparatedByString:@"\t"];
                NSString *type = lineOne[1];
                if ([type isEqualToString:@"video"]) {
                    RMVideoTrack *track = [[RMVideoTrack alloc] init];
                    [track setCodecString:lineOne[2]];
                    track.duration = [arr[2] doubleValue];
                    track.bitRate = [arr[4] integerValue];
                    NSArray *dim = [arr[6] componentsSeparatedByString:@"x"];
                    track.resolution = CGSizeMake([dim[0] integerValue], [dim[1] integerValue]);
                    track.frameRate = [arr[8] doubleValue];
                    [tracks addObject:track];
                } else if ([type isEqualToString:@"audio"]) {
                    RMAudioTrack *track = [[RMAudioTrack alloc] init];
                    [track setCodecString:lineOne[2]];
                    track.duration = [arr[1] doubleValue];
                    track.bitRate = [arr[3] integerValue];
                    track.sampleRate = [arr[5] doubleValue];
                    [tracks addObject:track];
                }
            }
        }
    }
    
    _tracks = [tracks copy];
    return _tracks;
}

- (NSString *)mp4infoPath {
    return @"/usr/local/bin/mp4info";
}

@end
