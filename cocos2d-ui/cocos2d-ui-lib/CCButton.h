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
    NSMutableDictionary* _backgroundSpriteFrames;
    NSMutableDictionary* _backgroundColors;
    NSMutableDictionary* _backgroundOpacities;
    NSMutableDictionary* _labelColors;
    NSMutableDictionary* _labelOpacities;
    float _originalScaleX;
    float _originalScaleY;
}

@property (nonatomic,readonly) CCSprite9Slice* background;
@property (nonatomic,readonly) CCLabelTTF* label;
@property (nonatomic,assign) BOOL zoomWhenHighlighted;
@property (nonatomic,assign) float horizontalPadding;
@property (nonatomic,assign) float verticalPadding;

+ (id) buttonWithTitle:(NSString*) title;
+ (id) buttonWithTitle:(NSString*) title spriteFrame:(CCSpriteFrame*) spriteFrame;
+ (id) buttonWithTitle:(NSString*) title spriteFrame:(CCSpriteFrame*) spriteFrame highlightedSpriteFrame:(CCSpriteFrame*) highlighted disabledSpriteFrame:(CCSpriteFrame*) disabled;

- (id) initWithTitle:(NSString*) title;
- (id) initWithTitle:(NSString*) title spriteFrame:(CCSpriteFrame*) spriteFrame;
- (id) initWithTitle:(NSString*) title spriteFrame:(CCSpriteFrame*) spriteFrame highlightedSpriteFrame:(CCSpriteFrame*) highlighted disabledSpriteFrame:(CCSpriteFrame*) disabled;

- (void) setBackgroundColor:(ccColor3B) color forState:(CCControlState) state;
- (void) setBackgroundOpacity:(GLubyte) opacity forState:(CCControlState) state;

- (void) setLabelColor:(ccColor3B) color forState:(CCControlState) state;
- (void) setLabelOpacity:(GLubyte) opacity forState:(CCControlState) state;

- (ccColor3B) backgroundColorForState:(CCControlState)state;
- (GLubyte) backgroundOpacityForState:(CCControlState)state;

- (ccColor3B) labelColorForState:(CCControlState) state;
- (GLubyte) labelOpacityForState:(CCControlState) state;

@end
