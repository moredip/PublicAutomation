//
//  UIAutomationBridge.m
//  PublicAutomation
//
//  Created by Pete Hodgson on 8/12/12.
//  Copyright (c) 2012 ThoughtWorks. All rights reserved.
//

#import "UIAutomationBridge.h"

@implementation UIAutomationBridge

+ (UIASyntheticEvents *)uia{
    return [NSClassFromString(@"UIASyntheticEvents") sharedEventGenerator];
}

+ (BOOL) checkForKeyboard {
    // this was lifted from KIF's UIApplication+KIFAdditions
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        if ([NSStringFromClass([window class]) isEqual:@"UITextEffectsWindow"]) {
            return YES;
        }
    }
    return NO;
}

@end
