//
//  main.m
//  remuxer
//
//  Created by Evan Coleman on 2/14/14.
//  Copyright (c) 2014 Evan Coleman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMRemuxerController.h"

int main(int argc, const char * argv[]) {

    @autoreleasepool {
        
        [[RMRemuxerController sharedInstance] processArgc:argc argv:argv];
    }
    return 0;
}

