//
//  UIAutomationBridge.m
//  PublicAutomation
//
//  Created by Pete Hodgson on 8/12/12.
//  Copyright (c) 2012 ThoughtWorks. All rights reserved.
//

#import "UIAutomationBridge.h"
#import "KIFTypist.h"

#import "CGGeometry-KIFAdditions.h"

@implementation UIAutomationBridge

+ (UIASyntheticEvents *)uia{
    return [NSClassFromString(@"UIASyntheticEvents") sharedEventGenerator];
}

+ (BOOL) checkForKeyboard {
    return [KIFTypist keyboardWindow] != nil;
}

+ (BOOL) typeIntoKeyboard:(NSString *)string {
    NSLog( @"typing into keyboard: %@", string );
    return [KIFTypist enterText:string];
}

+ (CGPoint) tapView:(UIView *)view {
    return [self tapView:view atPoint:CGPointCenteredInRect(view.bounds)];
}

+ (CGPoint) tapView:(UIView *)view atPoint:(CGPoint)point{
    CGPoint tapPoint = [view convertPoint:point toView:nil];
    NSLog(@"tapping at (%.2f,%.2f)", tapPoint.x,tapPoint.y);
    [[self uia] sendTap:tapPoint];
    
    return tapPoint;
}

@end
