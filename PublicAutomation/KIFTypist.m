//
//  KIFTypist.m
//  KIF
//
//  Created by Pete Hodgson on 8/12/12.
//
//

#import "KIFTypist.h"

#import "UIAutomationBridge.h"
#import "CGGeometry-KIFAdditions.h"

@interface KIFTypist()
+ (NSString *)_representedKeyboardStringForCharacter:(NSString *)characterString;
+ (BOOL)_enterCharacter:(NSString *)characterString history:(NSMutableDictionary *)history;

+ (NSArray *)_subviewsOfView:(UIView *)view withClassNamePrefix:(NSString *)prefix;
@end

@implementation KIFTypist

// Listed from UIApplication+KIFAdditions
+ (UIWindow *)keyboardWindow;
{
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        if ([NSStringFromClass([window class]) isEqual:@"UITextEffectsWindow"]) {
            return window;
        }
    }
    
    return nil;
}

+ (NSString *)_representedKeyboardStringForCharacter:(NSString *)characterString;
{
    // Interpret control characters appropriately
    if ([characterString isEqual:@"\b"]) {
        characterString = @"Delete";
    }
    
    return characterString;
}

+ (BOOL)enterCharacter:(NSString *)characterString;
{
    return [self _enterCharacter:characterString history:[NSMutableDictionary dictionary]];
}

+ (BOOL)_enterCharacter:(NSString *)characterString history:(NSMutableDictionary *)history;
{
    const NSTimeInterval keystrokeDelay = 0.05f;
    
    // Each key on the keyboard does not have its own view, so we have to ask for the list of keys,
    // find the appropriate one, and tap inside the frame of that key on the main keyboard view.
    if (!characterString.length) {
        return YES;
    }
    
    UIView *keyboardView = [[self _subviewsOfView:[self keyboardWindow] withClassNamePrefix:@"UIKBKeyplaneView"] lastObject];
    
    // If we didn't find the standard keyboard view, then we may have a custom keyboard
    if (!keyboardView) {
        // Custom keyboards not supported for now - I would have had to import more KIF stuff
        // than I wanted to.
        NSLog( @"Sorry, custom keyboards are currently not supported." );
        return NO;
    }
    
    id /*UIKBKeyplane*/ keyplane = [keyboardView valueForKey:@"keyplane"];
    BOOL isShiftKeyplane = [[keyplane valueForKey:@"isShiftKeyplane"] boolValue];
    
    NSMutableArray *unvisitedForKeyplane = [history objectForKey:[NSValue valueWithNonretainedObject:keyplane]];
    if (!unvisitedForKeyplane) {
        unvisitedForKeyplane = [NSMutableArray arrayWithObjects:@"More", @"International", nil];
        if (!isShiftKeyplane) {
            [unvisitedForKeyplane insertObject:@"Shift" atIndex:0];
        }
        [history setObject:unvisitedForKeyplane forKey:[NSValue valueWithNonretainedObject:keyplane]];
    }
    
    NSArray *keys = [keyplane valueForKey:@"keys"];
    
    // Interpret control characters appropriately
    characterString = [self _representedKeyboardStringForCharacter:characterString];
    
    id keyToTap = nil;
    id modifierKey = nil;
    NSString *selectedModifierRepresentedString = nil;
    
    while (YES) {
        for (id/*UIKBKey*/ key in keys) {
            NSString *representedString = [key valueForKey:@"representedString"];
            
            // Find the key based on the key's represented string
            if ([representedString isEqual:characterString]) {
                keyToTap = key;
            }
            
            if (!modifierKey && unvisitedForKeyplane.count && [[unvisitedForKeyplane objectAtIndex:0] isEqual:representedString]) {
                modifierKey = key;
                selectedModifierRepresentedString = representedString;
                [unvisitedForKeyplane removeObjectAtIndex:0];
            }
        }
        
        if (keyToTap) {
            break;
        }
        
        if (modifierKey) {
            break;
        }
        
        if (!unvisitedForKeyplane.count) {
            return NO;
        }
        
        // If we didn't find the key or the modifier, then this modifier must not exist on this keyboard. Remove it.
        [unvisitedForKeyplane removeObjectAtIndex:0];
    }
    
    if (keyToTap) {
        [UIAutomationBridge tapView:keyboardView atPoint:CGPointCenteredInRect([keyToTap frame])];
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, keystrokeDelay, false);
        
        return YES;
    }
    
    // We didn't find anything, so try the symbols pane
    if (modifierKey) {
        [UIAutomationBridge tapView:keyboardView atPoint:CGPointCenteredInRect([modifierKey frame])];
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, keystrokeDelay, false);
        
        // If we're back at a place we've been before, and we still have things to explore in the previous
        id /*UIKBKeyplane*/ newKeyplane = [keyboardView valueForKey:@"keyplane"];
        id /*UIKBKeyplane*/ previousKeyplane = [history valueForKey:@"previousKeyplane"];
        
        if (newKeyplane == previousKeyplane) {
            // Come back to the keyplane that we just tested so that we can try the other modifiers
            NSMutableArray *previousKeyplaneHistory = [history objectForKey:[NSValue valueWithNonretainedObject:newKeyplane]];
            [previousKeyplaneHistory insertObject:[history valueForKey:@"lastModifierRepresentedString"] atIndex:0];
        } else {
            [history setValue:keyplane forKey:@"previousKeyplane"];
            [history setValue:selectedModifierRepresentedString forKey:@"lastModifierRepresentedString"];
        }
        
        return [self _enterCharacter:characterString history:history];
    }
    
    return NO;
}


// Lifted from UIView+KIFAdditions
+ (NSArray *)_subviewsOfView:(UIView *)view withClassNamePrefix:(NSString *)prefix;
{
    NSMutableArray *result = [NSMutableArray array];
    
    // Breadth-first population of matching subviews
    // First traverse the next level of subviews, adding matches.
    for (UIView *subview in view.subviews) {
        if ([NSStringFromClass([subview class]) hasPrefix:prefix]) {
            [result addObject:subview];
        }
    }
    
    // Now traverse the subviews of the subviews, adding matches.
    for (UIView *subview in view.subviews) {
        NSArray *matchingSubviews = [self _subviewsOfView:subview withClassNamePrefix:prefix];
        [result addObjectsFromArray:matchingSubviews];
    }
    
    return result;
}

@end
