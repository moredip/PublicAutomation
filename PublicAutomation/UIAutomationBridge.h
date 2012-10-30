//
//  UIAutomationBridge.h
//  PublicAutomation
//
//  Created by Pete Hodgson on 8/12/12.
//  Copyright (c) 2012 ThoughtWorks. All rights reserved.
//
@class UIASyntheticEvents;
@class UIATarget;

typedef enum  {
    PADirectionLeft,
    PADirectionRight,
    PADirectionUp,
    PADirectionDown
}PADirection;


@interface UIAutomationBridge : NSObject

+ (UIASyntheticEvents *) uia;
+ (UIATarget *) uiat;

+ (BOOL) checkForKeyboard;
+ (BOOL) typeIntoKeyboard:(NSString *)string;
+ (void) setOrientation:(UIDeviceOrientation)orientation;

// It would be a slightly nicer API if we used CLLocation here instead of CGPoint, but that would
/// mean pulling in the whole CoreLocation framework, which seems a bit over-the-top for just this one method.
+ (void) setLocation:(CGPoint)locationAsPoint;

+ (CGPoint) tapView:(UIView *)view;
+ (CGPoint) tapView:(UIView *)view atPoint:(CGPoint)point;

+ (NSArray *) swipeView:(UIView *)view inDirection:(PADirection)dir;


+ (PADirection) parseDirection:(NSString *)direction;
@end
