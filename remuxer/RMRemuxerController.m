//
//  RMRemuxerController.m
//  remuxer
//
//  Created by Evan Coleman on 2/14/14.
//  Copyright (c) 2014 Evan Coleman. All rights reserved.
//

#import "RMRemuxerController.h"
#import "ColorMacros.h"
#import "RMVideoRemuxOperation.h"
#import "RMMP4File.h"
#import "RMMKVFile.h"
#import <JVArgumentParser/JVArgumentParser.h>

@interface RMRemuxerController ()

@property (nonatomic) NSString *inputPath;
@property (nonatomic) NSString *inputExtension;
@property (nonatomic) NSString *outputDirectory;

@property (nonatomic) NSMutableArray *filesToProcess;

@end

@implementation RMRemuxerController

+ (instancetype)sharedInstance {
    static RMRemuxerController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RMRemuxerController alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)processArgc:(int)argc argv:(const char **)argv {
    JVArgumentParser *parser = [JVArgumentParser argumentParser];
    
    __weak typeof(self) weakSelf = self;
    [parser addOptionWithArgumentWithName:'i' block:^(NSString *option){
        if (![[NSFileManager defaultManager] fileExistsAtPath:[option stringByExpandingTildeInPath]]) {
            printf(BOLDRED "Input path does not exist.\n" RESET);
            exit(0);
        } else {
            weakSelf.inputPath = [option stringByExpandingTildeInPath];
        }
    }];
    [parser addOptionWithArgumentWithName:'f' block:^(NSString *option){
        weakSelf.inputExtension = option;
    }];
    [parser addOptionWithArgumentWithName:'o' block:^(NSString *option){
        BOOL isDirectory;
        if (![[NSFileManager defaultManager] fileExistsAtPath:[option stringByExpandingTildeInPath] isDirectory:&isDirectory]) {
            printf(BOLDRED "Output path does not exist.\n" RESET);
            exit(0);
        } else {
            if (!isDirectory) {
                printf(BOLDRED "Output path must be a directory.\n" RESET);
                exit(0);
            } else {
                weakSelf.outputDirectory = [option stringByExpandingTildeInPath];
            }
        }
    }];
    
    (void)[parser parseArgc:argc argv:argv encoding:NSUTF8StringEncoding error:nil];
    
    [self begin];
}

#pragma mark - Private methods

- (void)begin {
    if (!self.inputPath) {
        self.inputPath = [[NSFileManager defaultManager] currentDirectoryPath];
    }
    
    if (!self.inputExtension) {
        self.inputExtension = @"mkv";
    }
    
    NSMutableArray *filesToProcess = [NSMutableArray array];
    
    BOOL isDirectory;
    [[NSFileManager defaultManager] fileExistsAtPath:self.inputPath isDirectory:&isDirectory];
    if (isDirectory) {
        if (!self.inputExtension) {
            printf(BOLDRED "Please provide input file extension using the -f option.\n" RESET);
            exit(0);
        }
        filesToProcess = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.inputPath error:nil] mutableCopy];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self ENDSWITH %@", self.inputExtension];
        [filesToProcess filterUsingPredicate:predicate];
    } else {
        filesToProcess = [NSMutableArray arrayWithObject:self.inputPath];
    }
    
    if ([filesToProcess count] == 0) {
        printf(BOLDRED "No files found in %s with extension %s\n" RESET, [self.inputPath UTF8String], [self.inputExtension UTF8String]);
        exit(0);
    }
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    for (NSString *fileName in filesToProcess) {
        NSString *filePath = [self.inputPath stringByAppendingPathComponent:fileName];
        RMFile *file = nil;
        if ([self.inputExtension isEqualToString:@"mp4"] || [self.inputExtension isEqualToString:@"m4v"]) {
            file = [[RMMP4File alloc] initWithPath:filePath];
        } else if ([self.inputExtension isEqualToString:@"mkv"]) {
            file = [[RMMKVFile alloc] initWithPath:filePath];
        }
        RMVideoRemuxOperation *op = [[RMVideoRemuxOperation alloc] initWithFile:file];
        [queue addOperation:op];
    }
    [queue waitUntilAllOperationsAreFinished];
}

@end
