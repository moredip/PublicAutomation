//
//  PALoader.m
//  PublicAutomation
//
//  Created by Pete Hodgson on 8/15/12.
//  Copyright (c) 2012 ThoughtWorks. All rights reserved.
//

#include <dlfcn.h>

@interface PALoader : NSObject

@end

@implementation PALoader

+ (void)load{
    NSLog(@"linking UIAutomation framework...");
    dlopen([@"/Developer/Library/PrivateFrameworks/UIAutomation.framework/UIAutomation" fileSystemRepresentation], RTLD_LOCAL);
}

@end
