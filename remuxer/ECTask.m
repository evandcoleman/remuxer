//
//  ECTask.m
//  remuxer
//
//  Created by Evan Coleman on 2/14/14.
//  Copyright (c) 2014 Evan Coleman. All rights reserved.
//

#import "ECTask.h"

@interface ECTask ()

@property (nonatomic) NSTask *task;
@property (nonatomic) NSString *output;
@property (nonatomic) NSPipe *pipe;

@end

@implementation ECTask

- (instancetype)initWithLaunchPath:(NSString *)launchPath {
    self = [self init];
    if (self) {
        _launchPath = launchPath;
        _task.launchPath = launchPath;
    }
    return self;
}
                 
- (instancetype)init {
    self = [super init];
    if (self) {
        _task = [[NSTask alloc] init];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleDataAvailableNotification object:nil];
}

#pragma mark - Setters

- (void)setArguments:(NSArray *)arguments {
    _arguments = arguments;
    self.task.arguments = arguments;
}

- (void)setLaunchPath:(NSString *)launchPath {
    _launchPath = launchPath;
    self.task.launchPath = launchPath;
}

#pragma mark - NSTask

- (void)launch {
    self.pipe = [NSPipe pipe];
    [self.task setStandardOutput:self.pipe];
    [self.task setStandardError:self.pipe];
    
    NSFileHandle *fileHandle = [self.pipe fileHandleForReading];
    if (self.outputBlock) {
        [fileHandle waitForDataInBackgroundAndNotify];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedData:) name:NSFileHandleDataAvailableNotification object:fileHandle];
    }
    
    [self.task launch];
}

- (void)waitUntilExit {
    [self.task waitUntilExit];
    NSData *output = [[self.pipe fileHandleForReading] availableData];
    self.output = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
}

- (void)receivedData:(NSNotification *)note {
    NSData *data = [[note object] availableData];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (self.outputBlock) {
        self.outputBlock(string);
    }
    [[note object] waitForDataInBackgroundAndNotify];
}

@end
