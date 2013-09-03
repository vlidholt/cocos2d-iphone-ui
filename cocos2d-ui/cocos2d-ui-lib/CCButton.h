//
//  CCButton.h
//  cocos2d-ui
//
//  Created by Viktor on 9/3/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "cocos2d.h"
#import "CCControl.h"

@interface CCButton : CCControl
{
    NSMutableDictionary* _backgroundColors;
    NSMutableDictionary* _labelColors;
}

@property (nonatomic,retain) CCSprite9Slice* background;
@property (nonatomic,retain) CCLabelTTF* label;
@property (nonatomic,assign) BOOL zoomWhenSelected;

- (id) initWithTitle:(NSString*) title;
- (id) initWithTitle:(NSString*) title spriteFrameName:(NSString*) frameName;

- (void) setBackgroundColor:(ccColor3B) color forState:(NSUInteger) state;
- (void) setLabelColor:(ccColor3B) color forState:(NSUInteger) state;

- (ccColor3B) backgroundColorForState:(NSUInteger)state;
- (ccColor3B) labelColorForState:(NSUInteger) state;

@end
