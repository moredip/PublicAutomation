//
//  UIView+PublicAutomation.m
//  PublicAutomation
//
//  Created by Pete Hodgson on 8/12/12.
//  Copyright (c) 2012 ThoughtWorks. All rights reserved.
//

#import "UIAutomation.h"
#import "UIAutomationBridge.h"

#import "CGGeometry-KIFAdditions.h"

#import "LoadableCategory.h"
MAKE_CATEGORIES_LOADABLE(UIView_PublicAutomation)

@implementation UIView (PublicAutomation)

- (id) PA_tap{
    CGPoint pointTapped = [UIAutomationBridge tapView:self];
    return [NSValue valueWithCGPoint:pointTapped];
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
CGSize swipeRatiosForDirection(NSString *direction){
    NSString *dir = [direction lowercaseString];
    
    if([dir isEqualToString:@"left"]){
        return CGSizeMake(-BIG_RATIO, SMALL_RATIO);
    }else if([dir isEqualToString:@"right"]){
        return CGSizeMake(BIG_RATIO, SMALL_RATIO);
    }else if([dir isEqualToString:@"up"]){
        return CGSizeMake(SMALL_RATIO, -BIG_RATIO);
    }else if([dir isEqualToString:@"down"]){
        return CGSizeMake(SMALL_RATIO, BIG_RATIO);
    }else{
        [NSException raise:@"invalid swipe direction" format:@"swipe direction '%@' is invalid", direction];
        return CGSizeZero; // just here to stop the compiler whining.
    }
}

- (NSString *) PA_swipe:(NSString *)dir{

    CGPoint swipeStart = [self.window convertPoint:CGPointCenteredInRect(self.bounds) fromView:self];
    CGSize ratios = swipeRatiosForDirection(dir);
    CGSize viewSize = self.bounds.size;
    CGPoint swipeEnd = CGPointMake(
                                   swipeStart.x+(ratios.width*viewSize.width),
                                   swipeStart.y+(ratios.height*viewSize.height)
                                   );
    
    NSString *swipeDescription = [NSString stringWithFormat:@"%@ => %@", NSStringFromCGPoint(swipeStart), NSStringFromCGPoint(swipeEnd)];
    
    [[UIAutomationBridge uia] sendDragWithStartPoint:swipeStart endPoint:swipeEnd duration:SWIPE_DURATION];

    return swipeDescription;
}

@end
