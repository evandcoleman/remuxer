//
//  RMAudioTrack.h
//  remuxer
//
//  Created by Evan Coleman on 2/16/14.
//  Copyright (c) 2014 Evan Coleman. All rights reserved.
//

#import "RMTrack.h"

typedef NS_ENUM(NSUInteger, RMAudioCodec) {
    RMAudioCodecAC3,
    RMAudioCodecAAC,
};

@interface RMAudioTrack : RMTrack

@property (nonatomic) RMAudioCodec codec;
@property (nonatomic) CGFloat sampleRate;

- (void)setCodecString:(NSString *)string;

@end
