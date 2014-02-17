//
//  RMSubtitleTrack.m
//  remuxer
//
//  Created by Evan Coleman on 2/16/14.
//  Copyright (c) 2014 Evan Coleman. All rights reserved.
//

#import "RMSubtitleTrack.h"

@implementation RMSubtitleTrack

- (void)setCodecString:(NSString *)string {
    if ([string isEqualToString:@"S_TEXT/UTF8"]) {
        self.codec = RMSubtitleCodecSRT;
    }
}

- (NSString *)description {
    NSString *codecString = nil;
    switch (self.codec) {
        case RMSubtitleCodecSRT:
            codecString = @"SRT";
            break;
        case RMSubtitleCodecTX3G:
            codecString = @"tx3g";
            break;
        default:
            codecString = @"null";
            break;
    }
    
    NSMutableString *retVal = [@"Subtitles: " mutableCopy];
    [retVal appendFormat:@"%@ ", codecString];
    
    return retVal;
}

@end
