//
//  CCScrollView.h
//  cocos2d-ui
//
//  Created by Viktor on 9/3/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface CCScrollView : CCNode <UIGestureRecognizerDelegate>
{
    UIPanGestureRecognizer* _panRecognizer;
    CGPoint _rawTranslationStart;
    CGPoint _startScrollPos;
}

@property (nonatomic,strong) CCNode* contentNode;

@property (nonatomic,readonly) float minScrollX;
@property (nonatomic,readonly) float maxScrollX;
@property (nonatomic,readonly) float minScrollY;
@property (nonatomic,readonly) float maxScrollY;

@property (nonatomic,assign) CGPoint scrollPosition;

- (id) initWithContentNode:(CCNode*)contentNode contentSize:(CGSize) contentSize;

@end
