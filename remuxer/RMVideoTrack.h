//
//  RMVideoTrack.h
//  remuxer
//
//  Created by Evan Coleman on 2/16/14.
//  Copyright (c) 2014 Evan Coleman. All rights reserved.
//

#import "RMTrack.h"

typedef NS_ENUM(NSUInteger, RMVideoCodec) {
    RMVideoCodecH264,
};

@interface RMVideoTrack : RMTrack

@property (nonatomic) RMVideoCodec codec;
@property (nonatomic) CGSize resolution;
@property (nonatomic) CGFloat frameRate;

- (void)setCodecString:(NSString *)string;

@end
