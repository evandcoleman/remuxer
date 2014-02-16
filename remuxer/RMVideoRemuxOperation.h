//
//  RMVideoRemuxer.h
//  remuxer
//
//  Created by Evan Coleman on 2/16/14.
//  Copyright (c) 2014 Evan Coleman. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RMFile;

@interface RMVideoRemuxOperation : NSOperation

@property (nonatomic, readonly) RMFile *file;

- (instancetype)initWithFile:(RMFile *)file;

@end
