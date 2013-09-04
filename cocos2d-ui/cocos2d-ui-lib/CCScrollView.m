/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2013 Apportable Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "CCScrollView.h"
#import "CCDirector.h"
#import "UITouch+CC.h"
#import "CGPointExtension.h"

#import <UIKit/UIGestureRecognizerSubclass.h>

#define kCCScrollViewBoundsSlowDown 0.5
#define kCCScrollViewBounceFilter 0.5
#define kCCScrollViewDeacceleration 0.95
#define kCCScrollViewVelocityLowerCap 20
#define kCCScrollViewAllowInteractionBelowVelocity 50

#pragma mark CCTapDownGestureRecognizer

@interface CCTapDownGestureRecognizer : UIGestureRecognizer
@end

@implementation CCTapDownGestureRecognizer

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.state == UIGestureRecognizerStatePossible)
    {
        self.state = UIGestureRecognizerStateRecognized;
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.state = UIGestureRecognizerStateFailed;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.state = UIGestureRecognizerStateFailed;
}
@end

#pragma mark -
#pragma mark CCScrollView

@implementation CCScrollView

#pragma mark Initializers

- (id) initWithContentNode:(CCNode*)contentNode contentSize:(CGSize) contentSize
{
    self = [super init];
    if (!self) return NULL;
    
    // Setup content node
    self.contentSize = contentSize;
    self.contentNode = contentNode;
    
    if (contentNode)
    {
        [self addChild:contentNode];
    }
    
    // Default properties
    _horizontalScrollEnabled = YES;
    _verticalScrollEnabled = YES;
    
    // Create gesture recognizers
    _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    _tapRecognizer = [[CCTapDownGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    
    // Do not start tracking gestures until scrollview is visible on screen
    _panRecognizer.enabled = NO;
    _tapRecognizer.enabled = NO;
    
    _panRecognizer.delegate = self;
    _tapRecognizer.delegate = self;
    
    // Add recognizer
    UIView* view = [CCDirector sharedDirector].view;
    [view setGestureRecognizers:[NSArray arrayWithObjects:_tapRecognizer,_panRecognizer, NULL]];
    
    [self scheduleUpdate];
    
    return self;
}

#pragma mark Min/Max size

- (float) minScrollX
{
    return 0;
}

- (float) maxScrollX
{
    if (!_contentNode) return 0;
    
    float maxScroll = _contentNode.contentSize.width - self.contentSize.width;
    if (maxScroll < 0) maxScroll = 0;
    
    return maxScroll;
}

- (float) minScrollY
{
    return 0;
}

- (float) maxScrollY
{
    return 0;
}

#pragma mark Panning and setting position

- (BOOL) moving
{
    return ((_velocity.x != 0 || _velocity.y != 0) && !_isPanning);
}

- (void) setScrollPosition:(CGPoint)newPos
{
    [self setScrollPosition:newPos animated:NO];
}

- (void) setScrollPosition:(CGPoint)newPos animated:(BOOL)animated
{
    // Check bounds
    if (newPos.x > self.maxScrollX) newPos.x = self.maxScrollX;
    if (newPos.x < self.minScrollX) newPos.x = self.minScrollX;
    if (newPos.y > self.maxScrollY) newPos.y = self.maxScrollY;
    if (newPos.y < self.minScrollY) newPos.y = self.minScrollY;
    
    if (animated)
    {
        _posTarget = newPos;
        _hasPosTargetX = YES;
        _hasPosTargetY = YES;
    }
    else
    {
        _contentNode.position = ccpMult(newPos, -1);
    }
}

- (CGPoint) scrollPosition
{
    return ccpMult(_contentNode.position, -1);
}

- (void) panLayerToTarget:(CGPoint) newPos
{
    // Scroll at half speed outside of bounds
    if (newPos.x > self.maxScrollX)
    {
        float diff = newPos.x - self.maxScrollX;
        newPos.x = self.maxScrollX + diff * kCCScrollViewBoundsSlowDown;
    }
    if (newPos.x < self.minScrollX)
    {
        float diff = self.minScrollX - newPos.x;
        newPos.x = self.minScrollX - diff * kCCScrollViewBoundsSlowDown;
    }
    if (newPos.y > self.maxScrollY)
    {
        float diff = newPos.y - self.maxScrollY;
        newPos.y = self.maxScrollY + diff * kCCScrollViewBoundsSlowDown;
    }
    if (newPos.y < self.minScrollY)
    {
        float diff = self.minScrollY - newPos.y;
        newPos.y = self.minScrollY - diff * kCCScrollViewBoundsSlowDown;
    }
    
    _contentNode.position = ccpMult(newPos, -1);
}

- (void) update:(ccTime)df
{
    float fps = 1.0/df;
    float p = 60/fps;
    
    if (!_isPanning)
    {
        if (_velocity.x != 0 || _velocity.y != 0)
        {
            CGPoint delta = ccpMult(_velocity, df);
            _contentNode.position = ccpAdd(_contentNode.position, delta);
            
            _velocity = ccpMult(_velocity, powf(kCCScrollViewDeacceleration,p));
            
            if (fabs(_velocity.x) < kCCScrollViewVelocityLowerCap) _velocity.x = 0;
            if (fabs(_velocity.y) < kCCScrollViewVelocityLowerCap) _velocity.y = 0;
        }
        
        // Check bounds and add position targets if applicable
        CGPoint newPos = self.scrollPosition;

        if (!_hasPosTargetX)
        {
            if (newPos.x > self.maxScrollX)
            {
                _posTarget.x = self.maxScrollX;
                _hasPosTargetX = YES;
            }
            if (newPos.x < self.minScrollX)
            {
                _posTarget.x = self.minScrollX;
                _hasPosTargetX = YES;
            }
        }

        if (!_hasPosTargetY)
        {
            if (newPos.y > self.maxScrollY)
            {
                _posTarget.y = self.maxScrollY;
                _hasPosTargetY = YES;
            }
            if (newPos.y < self.minScrollY)
            {
                _posTarget.y = self.minScrollY;
                _hasPosTargetY = YES;
            }
        }
        
        float filter = 1.0 - powf(1.0-kCCScrollViewBounceFilter, p);// clampf(kCCScrollViewBounceFilter/(60.0 * df), 0, 1);

        if (_hasPosTargetX)
        {
            newPos.x = _posTarget.x * filter + newPos.x * (1.0 - filter);
            
            if (fabs(newPos.x - _posTarget.x) < 0.5)
            {
                // Hit target
                newPos.x = _posTarget.x;
                _hasPosTargetX = NO;
            }
        }
        if (_hasPosTargetY)
        {
            newPos.y = _posTarget.y * filter + newPos.y * (1.0 - filter);
            
            if (fabs(newPos.y - _posTarget.y) < 0.5)
            {
                // Hit target
                newPos.y = _posTarget.y;
                _hasPosTargetY = NO;
            }
        }

        _contentNode.position = ccpMult(newPos, -1);
    }
}

#pragma mark Gesture recognizer

- (void)handlePan:(UIGestureRecognizer *)gestureRecognizer
{
    CCDirector* dir = [CCDirector sharedDirector];
    UIPanGestureRecognizer* pgr = (UIPanGestureRecognizer*)gestureRecognizer;
    
    CGPoint rawTranslation = [pgr translationInView:dir.view];
    rawTranslation = [dir convertToGL:rawTranslation];
    rawTranslation = [self convertToNodeSpace:rawTranslation];
    
    if (pgr.state == UIGestureRecognizerStateBegan)
    {
        _hasPosTargetX = NO;
        _hasPosTargetY = NO;
        _rawTranslationStart = rawTranslation;
        _startScrollPos = self.scrollPosition;
        _isPanning = YES;
    }
    else if (pgr.state == UIGestureRecognizerStateChanged)
    {
        // Calculate the translation in node space
        CGPoint translation = ccpSub(_rawTranslationStart, rawTranslation);
        
        // Check if scroll directions has been disabled
        if (!_horizontalScrollEnabled) translation.x = 0;
        if (!_verticalScrollEnabled) translation.y = 0;
        
        // Check bounds
        CGPoint newPos = ccpAdd(_startScrollPos, translation);
        
        // Update position
        [self panLayerToTarget:newPos];
    }
    else if (pgr.state == UIGestureRecognizerStateEnded)
    {
        // Calculate the velocity in node space
        CGPoint ref = [dir convertToGL:CGPointZero];
        ref = [self convertToNodeSpace:ref];
        
        CGPoint velocityRaw = [pgr velocityInView:dir.view];
        velocityRaw = [dir convertToGL:velocityRaw];
        velocityRaw = [self convertToNodeSpace:velocityRaw];
        
        _velocity = ccpSub(velocityRaw, ref);
        
        // Check if scroll directions has been disabled
        if (!_horizontalScrollEnabled) _velocity.x = 0;
        if (!_verticalScrollEnabled) _velocity.y = 0;
        
        _isPanning = NO;
    }
    else if (pgr.state == UIGestureRecognizerStateCancelled)
    {
        NSLog(@"Cancelled");
        
        _isPanning = NO;
    }
    else
    {
        NSLog(@"UNKOWN!");
    }
}

- (void) handleTap:(UIGestureRecognizer *)gestureRecognizer
{
    // Stop layer from moving
    _velocity = CGPointZero;
    
    // Snap to a whole position
    CGPoint pos = _contentNode.position;
    pos.x = roundf(pos.x);
    pos.y = roundf(pos.y);
    _contentNode.position = pos;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (!_contentNode) return NO;
    if (!self.visible) return NO;
    
    BOOL slowMove = (fabs(_velocity.x) < kCCScrollViewAllowInteractionBelowVelocity &&
                     fabs(_velocity.y) < kCCScrollViewAllowInteractionBelowVelocity);
    
    if (gestureRecognizer == _tapRecognizer && (slowMove || _isPanning))
    {
        NSLog(@"Skipping tap SLOW: %d",slowMove);
        return NO;
    }
    
    return [self hitTestWithWorldPos:[touch locationInWorld]];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return (otherGestureRecognizer == _panRecognizer || otherGestureRecognizer == _tapRecognizer);
}

- (void) onEnterTransitionDidFinish
{
    _panRecognizer.enabled = YES;
    _tapRecognizer.enabled = YES;
}

- (void) onExitTransitionDidStart
{
    _panRecognizer.enabled = NO;
    _tapRecognizer.enabled = NO;
}

@end
