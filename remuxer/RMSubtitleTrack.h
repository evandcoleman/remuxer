//
//  RMSubtitleTrack.h
//  remuxer
//
//  Created by Evan Coleman on 2/16/14.
//  Copyright (c) 2014 Evan Coleman. All rights reserved.
//

#import "RMTrack.h"

typedef NS_ENUM(NSUInteger, RMSubtitleCodec) {
    RMSubtitleCodecSRT,
    RMSubtitleCodecTX3G,
};

@interface RMSubtitleTrack : RMTrack

@property (nonatomic) RMSubtitleCodec codec;

- (void)setCodecString:(NSString *)string;

@end
