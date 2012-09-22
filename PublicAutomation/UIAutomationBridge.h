//
//  UIAutomationBridge.h
//  PublicAutomation
//
//  Created by Pete Hodgson on 8/12/12.
//  Copyright (c) 2012 ThoughtWorks. All rights reserved.
//
@class UIASyntheticEvents;

typedef enum  {
    PADirectionLeft,
    PADirectionRight,
    PADirectionUp,
    PADirectionDown
}PADirection;


@interface UIAutomationBridge : NSObject

+ (UIASyntheticEvents *) uia;

+ (BOOL) checkForKeyboard;
+ (BOOL) typeIntoKeyboard:(NSString *)string;
+ (void) setOrientation:(UIDeviceOrientation)orientation;

+ (CGPoint) tapView:(UIView *)view;
+ (CGPoint) tapView:(UIView *)view atPoint:(CGPoint)point;

+ (NSArray *) swipeView:(UIView *)view inDirection:(PADirection)dir;


+ (PADirection) parseDirection:(NSString *)direction;
@end
