//
//  RMRemuxerController.h
//  remuxer
//
//  Created by Evan Coleman on 2/14/14.
//  Copyright (c) 2014 Evan Coleman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RMRemuxerController : NSObject

@property (nonatomic, readonly) NSString *inputPath;
@property (nonatomic, readonly) NSString *inputExtension;
@property (nonatomic, readonly) NSString *outputDirectory;

+ (instancetype)sharedInstance;
- (void)processArgc:(int)argc argv:(const char **)argv;

@end
