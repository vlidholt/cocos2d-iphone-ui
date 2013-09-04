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

@implementation CCScrollView

#pragma mark Initializers

- (id) initWithContentNode:(CCNode*)contentNode contentSize:(CGSize) contentSize
{
    self = [super init];
    if (!self) return NULL;
    
    self.contentSize = contentSize;
    self.contentNode = contentNode;
    
    if (contentNode)
    {
        [self addChild:contentNode];
    }
    
    // Create a pan gesture recognizer
    _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    
    // Do not start tracking gestures until scrollview is visible on screen
    _panRecognizer.enabled = NO;
    
    // Add recognizer
    UIView* view = [CCDirector sharedDirector].view;
    [view setGestureRecognizers:[NSArray arrayWithObject:_panRecognizer]];
    
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

- (void) setScrollPosition:(CGPoint)newPos
{
    // Check bounds
    if (newPos.x > self.maxScrollX) newPos.x = self.maxScrollX;
    if (newPos.x < self.minScrollX) newPos.x = self.minScrollX;
    if (newPos.y > self.maxScrollY) newPos.y = self.maxScrollY;
    if (newPos.y < self.minScrollY) newPos.y = self.minScrollY;
    
    _contentNode.position = ccpMult(newPos, -1);
}

- (CGPoint) scrollPosition
{
    return ccpMult(_contentNode.position, -1);
}

#pragma mark Gesture recognizer

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer
{
    CCDirector* dir = [CCDirector sharedDirector];
    UIPanGestureRecognizer* pgr = (UIPanGestureRecognizer*)gestureRecognizer;
    
    CGPoint rawTranslation = [pgr translationInView:dir.view];
    rawTranslation = [dir convertToGL:rawTranslation];
    rawTranslation = [self convertToNodeSpace:rawTranslation];
    
    if (pgr.state == UIGestureRecognizerStateBegan)
    {
        _rawTranslationStart = rawTranslation;
        _startScrollPos = self.scrollPosition;
    }
    else if (pgr.state == UIGestureRecognizerStateChanged)
    {
        // Calculate the translation in node space
        CGPoint translation = ccpSub(_rawTranslationStart, rawTranslation);
        NSLog(@"Changed (%f,%f)", translation.x, translation.y);
        
        // Check bounds
        CGPoint newPos = ccpAdd(_startScrollPos, translation);
        
        // Update position
        self.scrollPosition = newPos;
    }
    else if (pgr.state == UIGestureRecognizerStateEnded)
    {
        // Calculate the velocity in node space
        CGPoint ref = [dir convertToGL:CGPointZero];
        ref = [self convertToNodeSpace:ref];
        
        CGPoint velocityRaw = [pgr velocityInView:dir.view];
        velocityRaw = [dir convertToGL:velocityRaw];
        velocityRaw = [self convertToNodeSpace:velocityRaw];
        
        CGPoint velocity = ccpSub(velocityRaw, ref);
        
        NSLog(@"Velocity: (%f,%f)", velocity.x, velocity.y);
        
        //NSLog(@"Ended (%f,%f)", translation.x, translation.y);
    }
    else if (pgr.state == UIGestureRecognizerStateCancelled)
    {
        NSLog(@"Cancelled");
    }
    else
    {
        NSLog(@"UNKOWN!");
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (!_contentNode) return NO;
    if (!self.visible) return NO;
    return [self hitTestWithWorldPos:[touch locationInWorld]];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

- (void) onEnterTransitionDidFinish
{
    _panRecognizer.enabled = YES;
}

- (void) onExitTransitionDidStart
{
    _panRecognizer.enabled = NO;
}

@end
