//
//  ECTask.h
//  remuxer
//
//  Created by Evan Coleman on 2/14/14.
//  Copyright (c) 2014 Evan Coleman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ECTask : NSObject

@property (nonatomic) NSString *launchPath;
@property (nonatomic) NSArray *arguments;
@property (nonatomic, copy) void (^outputBlock)(NSString *);
@property (nonatomic, readonly) NSString *output;

- (instancetype)initWithLaunchPath:(NSString *)launchPath;
- (void)launch;
- (void)waitUntilExit;

@end
