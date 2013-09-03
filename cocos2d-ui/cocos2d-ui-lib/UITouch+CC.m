//
//  UITouch+CC.m
//  cocos2d-ui
//
//  Created by Viktor on 9/2/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "UITouch+CC.h"

@implementation UITouch (CC)

- (CGPoint) locationInNode:(CCNode*) node
{
    CCDirector* dir = [CCDirector sharedDirector];
    
    CGPoint touchLocation = [self locationInView: [self view]];
	touchLocation = [dir convertToGL: touchLocation];
    return [node convertToNodeSpace:touchLocation];
}

- (CGPoint) locationInWorld
{
    CCDirector* dir = [CCDirector sharedDirector];
    
    CGPoint touchLocation = [self locationInView: [self view]];
	return [dir convertToGL: touchLocation];
}

@end
