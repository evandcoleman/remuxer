//
//  RMFile.h
//  remuxer
//
//  Created by Evan Coleman on 2/16/14.
//  Copyright (c) 2014 Evan Coleman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMVideoTrack.h"
#import "RMAudioTrack.h"

@interface RMFile : NSObject {
    @protected
    NSArray *_tracks;
}

@property (nonatomic, readonly) NSString *path;
@property (nonatomic, readonly) NSArray *tracks;
@property (nonatomic, readonly) NSString *container;

- (instancetype)initWithPath:(NSString *)path;
- (RMVideoTrack *)firstVideoTrack;
- (RMAudioTrack *)firstAudioTrack;
- (NSUInteger)indexOfFirstVideoTrack;
- (NSUInteger)indexOfFirstAudioTrack;

// Subclasses must implement this method synchronously
- (NSArray *)readFileTracks;

@end
