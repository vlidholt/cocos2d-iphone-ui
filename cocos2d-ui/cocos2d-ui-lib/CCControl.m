//
//  CCControl.m
//  cocos2d-ui
//
//  Created by Viktor on 9/2/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "CCControl.h"
#import "UITouch+CC.h"
#import <objc/message.h>

@implementation CCControl

#pragma mark Initializers

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    self.userInteractionEnabled = YES;
    
    return self;
}

#pragma mark Action handling

- (void) setTarget:(id)target selector:(SEL)selector
{
    __unsafe_unretained id weakTarget = target; // avoid retain cycle
    [self setBlock:^(id sender) {
        objc_msgSend(weakTarget, selector, sender);
	}];
}

- (void) triggerAction
{
    if (self.enabled && _block)
    {
        _block(self);
    }
}

#pragma mark Touch handling

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    
    _tracking = YES;
    _touchInside = YES;
    
    [self touchEntered:touch withEvent:event];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    
    if ([self hitTestWithWorldPos:[touch locationInWorld]])
    {
        if (!_touchInside)
        {
            [self touchEntered:touch withEvent:event];
            _touchInside = YES;
        }
    }
    else
    {
        if (_touchInside)
        {
            [self touchExited:touch withEvent:event];
            _touchInside = NO;
        }
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    
    if (_touchInside)
    {
        [self touchUpInside:touch withEvent:event];
    }
    else
    {
        [self touchUpOutside:touch withEvent:event];
    }
    
    _touchInside = NO;
    _tracking = NO;
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    
    if (_touchInside)
    {
        [self touchExited:touch withEvent:event];
    }
    
    _touchInside = NO;
    _tracking = NO;
}

- (void) touchEntered:(UITouch*) touch withEvent:(UIEvent*)event
{}

- (void) touchExited:(UITouch*) touch withEvent:(UIEvent*) event
{}

- (void) touchUpInside:(UITouch*) touch withEvent:(UIEvent*) event
{}

- (void) touchUpOutside:(UITouch*) touch withEvent:(UIEvent*) event
{}


#pragma mark State properties

- (BOOL) enabled
{
    if (!(_state & CCControlStateDisabled)) return YES;
    else return NO;
}

- (void) setEnabled:(BOOL)enabled
{
    if (self.enabled == enabled) return;
    
    BOOL disabled = !enabled;
    
    if (disabled)
    {
        _state |= CCControlStateDisabled;
    }
    else
    {
        _state &= ~CCControlStateDisabled;
    }
    
    [self stateChanged];
}

- (BOOL) selected
{
    if (_state & CCControlStateSelected) return YES;
    else return NO;
}

- (void) setSelected:(BOOL)selected
{
    if (self.selected == selected) return;
    
    if (selected)
    {
        _state |= CCControlStateSelected;
    }
    else
    {
        _state &= ~CCControlStateSelected;
    }
    
    [self stateChanged];
}

- (BOOL) highlighted
{
    if (_state & CCControlStateHighlighted) return YES;
    else return NO;
}

- (void) setHighlighted:(BOOL)highlighted
{
    if (self.highlighted == highlighted) return;
    
    if (highlighted)
    {
        _state |= CCControlStateHighlighted;
    }
    else
    {
        _state &= ~CCControlStateHighlighted;
    }
    
    [self stateChanged];
}

#pragma mark Layout and state changes

- (void) stateChanged
{
    [self needsLayout];
}

- (void) needsLayout
{
    _needsLayout = YES;
}

- (void) layout
{
    _needsLayout = NO;
}

- (void) visit
{
    if (_needsLayout) [self layout];
    [super visit];
}

- (CGSize) contentSize
{
    if (_needsLayout) [self layout];
    return [super contentSize];
}

@end