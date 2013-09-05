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
#define kCCScrollViewDeacceleration 0.95
#define kCCScrollViewVelocityLowerCap 20.0
#define kCCScrollViewAllowInteractionBelowVelocity 50.0
#define kCCScrollViewSnapDuration 0.4
#define kCCScrollViewSnapDurationFallOff 100.0
#define kCCScrollViewAutoPageSpeed 500.0
#define kCCScrollViewMaxOuterDistBeforeBounceBack 50.0
#define kCCScrollViewMinVelocityBeforeBounceBack 100.0

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
    if (!_contentNode) return 0;
    
    float maxScroll = _contentNode.contentSize.height - self.contentSize.height;
    if (maxScroll < 0) maxScroll = 0;
    
    return maxScroll;
}

- (int) numHorizontalPages
{
    if (!_pagingEnabled) return 0;
    if (!self.contentSize.width || !_contentNode.contentSize.width) return 0;
    
    return _contentNode.contentSize.width / self.contentSize.width;
}

- (int) numVerticalPages
{
    if (!_pagingEnabled) return 0;
    if (!self.contentSize.height || !_contentNode.contentSize.height) return 0;
    
    return _contentNode.contentSize.height / self.contentSize.height;
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
    [_contentNode stopAllActions];
    
    // Check bounds
    if (newPos.x > self.maxScrollX) newPos.x = self.maxScrollX;
    if (newPos.x < self.minScrollX) newPos.x = self.minScrollX;
    if (newPos.y > self.maxScrollY) newPos.y = self.maxScrollY;
    if (newPos.y < self.minScrollY) newPos.y = self.minScrollY;
    
    if (animated)
    {
        CGPoint oldPos = self.scrollPosition;
        float dist = ccpDistance(newPos, oldPos);
        
        float duration = clampf(dist / kCCScrollViewSnapDurationFallOff, 0, kCCScrollViewSnapDuration);
        
        _velocity = CGPointZero;
        
        CCAction* action = [CCEaseOut actionWithAction:[CCMoveTo actionWithDuration:duration position:ccpMult(newPos, -1)] rate:2];
        
        [_contentNode runAction:action];
        
        _animating = YES;
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
            
            // Deaccelerate layer
            float deaccelerationX = kCCScrollViewDeacceleration;
            float deaccelerationY = kCCScrollViewDeacceleration;
            
            // Adjust for frame rate
            deaccelerationX = powf(deaccelerationX, p);
            
            // Update velocity
            _velocity.x *= deaccelerationX;
            _velocity.y *= deaccelerationY;
            
            // If velocity is low make it 0
            if (fabs(_velocity.x) < kCCScrollViewVelocityLowerCap) _velocity.x = 0;
            if (fabs(_velocity.y) < kCCScrollViewVelocityLowerCap) _velocity.y = 0;
        }
        
        // Bounce back to edge if layer is too far outside of the scroll area or if it is outside and moving slowly
        BOOL bounceToEdge = NO;
        CGPoint posTarget = self.scrollPosition;
        
        if (!_animating && !_pagingEnabled)
        {
            if ((posTarget.x < self.minScrollX && fabs(_velocity.x) < kCCScrollViewMinVelocityBeforeBounceBack) ||
                (posTarget.x < self.minScrollX - kCCScrollViewMaxOuterDistBeforeBounceBack))
            {
                bounceToEdge = YES;
            }
            
            if ((posTarget.x > self.maxScrollX && fabs(_velocity.x) < kCCScrollViewMinVelocityBeforeBounceBack) ||
                (posTarget.x > self.maxScrollX + kCCScrollViewMaxOuterDistBeforeBounceBack))
            {
                bounceToEdge = YES;
            }
            
            if ((posTarget.y < self.minScrollY && fabs(_velocity.y) < kCCScrollViewMinVelocityBeforeBounceBack) ||
                (posTarget.y < self.minScrollY - kCCScrollViewMaxOuterDistBeforeBounceBack))
            {
                bounceToEdge = YES;
            }
            
            if ((posTarget.y > self.maxScrollY && fabs(_velocity.y) < kCCScrollViewMinVelocityBeforeBounceBack) ||
                (posTarget.y > self.maxScrollY + kCCScrollViewMaxOuterDistBeforeBounceBack))
            {
                bounceToEdge = YES;
            }
            
            if (bounceToEdge)
            {
                // TODO: Doesn't bounces back on both axis, when it should only bounce back on the axis that is out of bounds (other axis shouldn't slow down)
                [self setScrollPosition:posTarget animated:YES];
            }
        }
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
        _animating = NO;
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
        
        // Setup a target if paging is enabled
        if (_pagingEnabled)
        {
            CGPoint posTarget = CGPointZero;
            
            // Calculate new horizontal page
            int pageX = roundf(self.scrollPosition.x/self.contentSize.width);
            
            if (fabs(_velocity.x) >= kCCScrollViewAutoPageSpeed && _horizontalPage == pageX)
            {
                if (_velocity.x < 0) pageX += 1;
                else pageX -= 1;
            }
            
            pageX = clampf(pageX, 0, self.numHorizontalPages -1);
            _horizontalPage = pageX;
            
            posTarget.x = pageX * self.contentSize.width;
            
            // Calculate new vertical page
            int pageY = roundf(self.scrollPosition.y/self.contentSize.height);
            
            if (fabs(_velocity.y) >= kCCScrollViewAutoPageSpeed && _verticalPage == pageY)
            {
                if (_velocity.y < 0) pageY += 1;
                else pageY -= 1;
            }
            
            pageY = clampf(pageY, 0, self.numVerticalPages -1);
            _verticalPage = pageY;
            
            posTarget.y = pageY * self.contentSize.height;
            
            [self setScrollPosition:posTarget animated:YES];
        }
        
        _isPanning = NO;
    }
    else if (pgr.state == UIGestureRecognizerStateCancelled)
    {
        _isPanning = NO;
        _velocity = CGPointZero;
        _animating = NO;
        
        [self setScrollPosition:self.scrollPosition animated:NO];
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
