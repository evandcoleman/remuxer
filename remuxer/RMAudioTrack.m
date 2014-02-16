//
//  RMAudioTrack.m
//  remuxer
//
//  Created by Evan Coleman on 2/16/14.
//  Copyright (c) 2014 Evan Coleman. All rights reserved.
//

#import "RMAudioTrack.h"

@implementation RMAudioTrack

- (void)setCodecString:(NSString *)string {
    if ([string isEqualToString:@"ac-3"] || [string isEqualToString:@"A_AC3"]) {
        self.codec = RMAudioCodecAC3;
    }
}

- (NSString *)description {
    NSString *codecString = nil;
    switch (self.codec) {
        case RMAudioCodecAC3:
            codecString = @"AC3";
            break;
        default:
            codecString = @"null";
            break;
    }
    
    NSMutableString *retVal = [@"Audio: " mutableCopy];
    [retVal appendFormat:@"%@ ", codecString];
    
    return retVal;
}

@end
