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

#import "CCNode.h"

@class CCTapDownGestureRecognizer;

@interface CCScrollView : CCNode <UIGestureRecognizerDelegate>
{
    UIPanGestureRecognizer* _panRecognizer;
    CCTapDownGestureRecognizer* _tapRecognizer;
    
    CGPoint _rawTranslationStart;
    CGPoint _startScrollPos;
    BOOL _isPanning;
    CGPoint _velocity;
    BOOL _hasPosTargetX;
    BOOL _hasPosTargetY;
    CGPoint _posTarget;
}

@property (nonatomic,strong) CCNode* contentNode;

@property (nonatomic,assign) BOOL horizontalScrollEnabled;
@property (nonatomic,assign) BOOL verticalScrollEnabled;

@property (nonatomic,readonly) float minScrollX;
@property (nonatomic,readonly) float maxScrollX;
@property (nonatomic,readonly) float minScrollY;
@property (nonatomic,readonly) float maxScrollY;

@property (nonatomic,assign) CGPoint scrollPosition;
@property (nonatomic,readonly) BOOL moving;

- (id) initWithContentNode:(CCNode*)contentNode contentSize:(CGSize) contentSize;

@end
