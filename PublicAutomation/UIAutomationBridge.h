//
//  UIAutomationBridge.h
//  PublicAutomation
//
//  Created by Pete Hodgson on 8/12/12.
//  Copyright (c) 2012 ThoughtWorks. All rights reserved.
//
#import "UIAutomation.h"

@interface UIAutomationBridge : NSObject

+ (UIASyntheticEvents *) uia;

+ (BOOL) checkForKeyboard;
+ (BOOL) typeIntoKeyboard:(NSString *)string;
+ (CGPoint) tapView:(UIView *)view;
+ (CGPoint) tapView:(UIView *)view atPoint:(CGPoint)point;

@end
