//
//  RMFile.m
//  remuxer
//
//  Created by Evan Coleman on 2/16/14.
//  Copyright (c) 2014 Evan Coleman. All rights reserved.
//

#import "RMFile.h"

@interface RMFile ()

@property (nonatomic) NSString *path;

@end

@implementation RMFile

- (instancetype)initWithPath:(NSString *)path {
    self = [super init];
    if (self) {
        _path = path;
    }
    return self;
}

- (NSString *)container {
    return [self.path pathExtension];
}

- (RMVideoTrack *)firstVideoTrack {
    for (RMTrack *track in self.tracks) {
        if ([track isKindOfClass:[RMVideoTrack class]]) {
            return (RMVideoTrack *)track;
        }
    }
    return nil;
}

- (RMAudioTrack *)firstAudioTrack {
    for (RMTrack *track in self.tracks) {
        if ([track isKindOfClass:[RMAudioTrack class]]) {
            return (RMAudioTrack *)track;
        }
    }
    return nil;
}

- (NSUInteger)indexOfFirstVideoTrack {
    return [self.tracks indexOfObject:[self firstVideoTrack]];
}

- (NSUInteger)indexOfFirstAudioTrack {
    return [self.tracks indexOfObject:[self firstAudioTrack]];
}

- (NSArray *)readFileTracks {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

@end
