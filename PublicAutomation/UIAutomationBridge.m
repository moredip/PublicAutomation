//
//  UIAutomationBridge.m
//  PublicAutomation
//
//  Created by Pete Hodgson on 8/12/12.
//  Copyright (c) 2012 ThoughtWorks. All rights reserved.
//
#import "UIAutomationBridge.h"
#import "UIAutomation.h"
#import "KIFTypist.h"

#import "CGGeometry-KIFAdditions.h"

#define INITIAL_DRAG_DELAY (0.20)
#define DEFAULT_DRAG_DURATION (0.10)
#define NUM_POINTS_IN_DRAG (100)

@implementation UIAutomationBridge

+ (UIASyntheticEvents *)uia{
    return [NSClassFromString(@"UIASyntheticEvents") sharedEventGenerator];
}

+ (UIATarget *)uiat{
    return [NSClassFromString(@"UIATarget") localTarget];
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

+ (CGPoint) downView:(UIView *)view {
    return [self downView:view atPoint:CGPointCenteredInRect(view.bounds)];
}

+ (CGPoint) downView:(UIView *)view atPoint:(CGPoint)point{
    CGPoint tapPoint = [view convertPoint:point toView:nil];
    return [self downPoint:tapPoint];
}

+ (CGPoint) downPoint:(CGPoint)point{
    NSLog(@"down at (%.2f,%.2f)", point.x,point.y);
    [[self uia] touchDown:point];
    return point;
}

+ (CGPoint) upView:(UIView *)view {
    return [self upView:view atPoint:CGPointCenteredInRect(view.bounds)];
}

+ (CGPoint) upView:(UIView *)view atPoint:(CGPoint)point{
    CGPoint tapPoint = [view convertPoint:point toView:nil];
    return [self upPoint:tapPoint];
}

+ (CGPoint) upPoint:(CGPoint)point{
    NSLog(@"up at (%.2f,%.2f)", point.x,point.y);
    [[self uia] liftUp:point];
    return point;
}

+ (CGPoint) longTapView:(UIView *)view forDuration:(NSTimeInterval)duration{
    return [self longTapView:view atPoint:CGPointCenteredInRect(view.bounds) forDuration:duration];
}

+ (CGPoint) longTapView:(UIView *)view atPoint:(CGPoint)point forDuration:(NSTimeInterval)duration{
    CGPoint tapPoint = [view convertPoint:point toView:nil];
    NSLog(@"long tapping at (%.2f,%.2f) for %.1f seconds", tapPoint.x,tapPoint.y, duration);
    [[self uia] touchDown:tapPoint];
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, duration, false);
    [[self uia] liftUp:tapPoint];
    return tapPoint;
}

+ (CGPoint) doubleTapView:(UIView *)view{
    return [self doubleTapView:view atPoint:CGPointCenteredInRect(view.bounds)];
}

+ (CGPoint) doubleTapView:(UIView *)view atPoint:(CGPoint)point{
    CGPoint tapPoint = [view convertPoint:point toView:nil];
    NSLog(@"double tapping at (%.2f,%.2f)", tapPoint.x,tapPoint.y);
    [[self uia] sendDoubleTap:tapPoint];
    return tapPoint;
}

+ (void) dragViewWithInitialDelay:(UIView *)view toPoint:(CGPoint)destPoint {
    [self dragViewWithInitialDelay:view toPoint:destPoint duration:DEFAULT_DRAG_DURATION];
}
+ (void) dragViewWithInitialDelay:(UIView *)view toPoint:(CGPoint)destPoint duration:(NSTimeInterval)duration{
    CGPoint startPoint = [view convertPoint:CGPointCenteredInRect(view.bounds) toView:nil];
    NSLog(@"dragging from (%.2f,%.2f) to (%.2f,%.2f) with duration %f", startPoint.x,startPoint.y,destPoint.x,destPoint.y,duration);
    
    CGPoint dragDelta = CGPointMake(destPoint.x-startPoint.x, destPoint.y-startPoint.y);
    
    [[self uia] touchDown:startPoint];
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, INITIAL_DRAG_DELAY, false);
    
    NSTimeInterval pauseBetweenPoints = duration/NUM_POINTS_IN_DRAG;
    for( int i = 0; i < NUM_POINTS_IN_DRAG; i++ ){
        CGFloat progress = ((CGFloat)i)/NUM_POINTS_IN_DRAG;
        CGPoint nextPoint = CGPointMake(
                                        startPoint.x + (dragDelta.x*progress),
                                        startPoint.y + (dragDelta.y*progress)
                                        );
        [[self uia] _moveLastTouchPoint:nextPoint];
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, pauseBetweenPoints, false);
    }
    [[self uia] liftUp:destPoint];
}

+ (void) setOrientation:(UIDeviceOrientation)orientation{
    [[self uia] setOrientation:(int)orientation];
}

+ (void) setLocation:(CGPoint)locationAsPoint{
    NSDictionary *locationDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithFloat:locationAsPoint.x], @"latitude",
                                      [NSNumber numberWithFloat:locationAsPoint.y], @"longitude",
                                   nil];
    [[self uiat] setLocation:locationDict];
}


// THESE MAGIC NUMBERS ARE IMPORTANT. From experimentation it appears that too big or too small a ration leads to
// gestures not being recognized as such by the system. For example setting the big ratio to 0.4 leads to
// swipe-to-delete not working on UITableViewCells.
// Also note that we always include at least a small component in each axes because in the past totally 'right-angled'
//swipes weren't detected properly. But we were using a different approach to touch simulation then,
//so this might now be unnecessary.
#define BIG_RATIO (0.3)
#define SMALL_RATIO (0.05)
#define SWIPE_DURATION (0.1)

//returns what portion of the view to swipe along in the x and y axes.
CGSize swipeRatiosForDirection(PADirection direction){
    switch (direction) {
        case PADirectionLeft:
            return CGSizeMake(-BIG_RATIO, SMALL_RATIO);
        case PADirectionRight:
            return CGSizeMake(BIG_RATIO, SMALL_RATIO);
        case PADirectionUp:
            return CGSizeMake(SMALL_RATIO, -BIG_RATIO);
        case PADirectionDown:
            return CGSizeMake(SMALL_RATIO, BIG_RATIO);
        default:
            [NSException raise:@"invalid swipe direction" format:@"swipe direction '%i' is invalid", direction];
            return CGSizeZero; // just here to stop the compiler whining.
    }
    }

+ (NSArray *) swipeView:(UIView *)view inDirection:(PADirection)dir {
    
    CGPoint swipeStart = [view convertPoint:CGPointCenteredInRect(view.bounds) toView:nil];
    CGSize ratios = swipeRatiosForDirection(dir);
    CGSize viewSize = view.bounds.size;
    CGPoint swipeEnd = CGPointMake(
                                   swipeStart.x+(ratios.width*viewSize.width),
                                   swipeStart.y+(ratios.height*viewSize.height)
                                   );
        
    [[UIAutomationBridge uia] sendDragWithStartPoint:swipeStart endPoint:swipeEnd duration:SWIPE_DURATION];
    
    return [NSArray arrayWithObjects:[NSValue valueWithCGPoint:swipeStart], [NSValue valueWithCGPoint:swipeEnd], nil];
}


+ (PADirection) parseDirection:(NSString *)direction{
    NSString *dir = [direction lowercaseString];
    
    if([dir isEqualToString:@"left"]){
        return PADirectionLeft;
    }else if([dir isEqualToString:@"right"]){
        return PADirectionRight;
    }else if([dir isEqualToString:@"up"]){
        return PADirectionUp;
    }else if([dir isEqualToString:@"down"]){
        return PADirectionDown;
    }else{
        [NSException raise:@"invalid swipe direction" format:@"swipe direction '%@' is invalid", direction];
        return 0;
    }
}

+ (BOOL)dragThumbInSlider:(UIView*)slider toValue:(double)value withDuration:(NSTimeInterval)duration {
    
    //[NSException raise:@"a" format:@"%@",NSStringFromClass([slider class]) ];
    if ( ![slider isKindOfClass:[UISlider class]] )
        return false;
    
    UISlider * theSlider = (UISlider*)slider;
    
    if ( value<theSlider.minimumValue || value>theSlider.maximumValue )
        return false;
    
    CGRect bounds = theSlider.bounds;
    // Apple recommends not calling the folowing methods,
    // but I haven't seen any side effects.
    CGRect trackRect = [theSlider trackRectForBounds:bounds];
    CGRect actualThumbRect = [theSlider thumbRectForBounds:bounds trackRect:trackRect value:theSlider.value];
    CGRect targetThumbRect = [theSlider thumbRectForBounds:bounds trackRect:trackRect value:value];
    
    
    CGPoint startPointInSlider = CGPointMake(actualThumbRect.origin.x+actualThumbRect.size.width/2,
                                             actualThumbRect.origin.y+actualThumbRect.size.height/2);
    
    CGPoint destPointInSlider = CGPointMake(targetThumbRect.origin.x+targetThumbRect.size.width/2,
                                            targetThumbRect.origin.y+targetThumbRect.size.height/2);
    
    CGPoint startPoint = [theSlider convertPoint:startPointInSlider toView:nil];
    CGPoint destPoint = [theSlider convertPoint:destPointInSlider toView:nil];
    
    // copy-pasted code from [UIAUtomationBridge dragView...], didn't feel entitled to refactor it
    NSLog(@"dragging slider's thumb from (%.2f,%.2f) to (%.2f,%.2f) with duration %f, value %f", startPoint.x,startPoint.y,destPoint.x,destPoint.y,duration,value);
    CGPoint dragDelta = CGPointMake(destPoint.x-startPoint.x, destPoint.y-startPoint.y);
    
    [[self uia] touchDown:startPoint];
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, INITIAL_DRAG_DELAY, false);
    
    NSTimeInterval pauseBetweenPoints = duration/NUM_POINTS_IN_DRAG;
    for( int i = 0; i < NUM_POINTS_IN_DRAG; i++ ){
        CGFloat progress = ((CGFloat)i)/NUM_POINTS_IN_DRAG;
        CGPoint nextPoint = CGPointMake(
                                        startPoint.x + (dragDelta.x*progress),
                                        startPoint.y + (dragDelta.y*progress)
                                        );
        [[self uia] _moveLastTouchPoint:nextPoint];
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, pauseBetweenPoints, false);
    }
    [[self uia] liftUp:destPoint];
    
    return true;
}

+ (BOOL)dragThumbInSlider:(UIView*)slider toValue:(double)value {
    return [self dragThumbInSlider:slider toValue:value withDuration:DEFAULT_DRAG_DURATION];
}

@end
