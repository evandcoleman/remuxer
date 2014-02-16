//
//  RMVideoTrack.m
//  remuxer
//
//  Created by Evan Coleman on 2/16/14.
//  Copyright (c) 2014 Evan Coleman. All rights reserved.
//

#import "RMVideoTrack.h"

@implementation RMVideoTrack

- (void)setCodecString:(NSString *)string {
    if ([string isEqualToString:@"H264"] || [string isEqualToString:@"V_MPEG4/ISO/AVC"]) {
        self.codec = RMVideoCodecH264;
    }
}

- (NSString *)description {
    NSString *codecString = nil;
    switch (self.codec) {
        case RMVideoCodecH264:
            codecString = @"H264";
            break;
        default:
            codecString = @"null";
            break;
    }
    
    NSMutableString *retVal = [@"Video: " mutableCopy];
    [retVal appendFormat:@"%@ ", codecString];
    
    return retVal;
}

@end
