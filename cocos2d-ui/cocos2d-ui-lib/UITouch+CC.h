//
//  UITouch+CC.h
//  cocos2d-ui
//
//  Created by Viktor on 9/2/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "cocos2d.h"
#import <UIKit/UIKit.h>

@interface UITouch (CC)

- (CGPoint) locationInNode:(CCNode*) node;
- (CGPoint) locationInWorld;
@end
