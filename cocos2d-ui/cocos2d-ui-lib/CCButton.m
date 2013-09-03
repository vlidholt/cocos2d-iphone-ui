//
//  CCButton.m
//  cocos2d-ui
//
//  Created by Viktor on 9/3/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "CCButton.h"

@implementation CCButton

- (id) init
{
    return [self initWithTitle:@"" spriteFrameName:NULL];
}

- (id) initWithTitle:(NSString *)title
{
    return [self initWithTitle:title spriteFrameName:NULL];
}

- (id) initWithTitle:(NSString*) title spriteFrameName:(NSString*) frameName
{
    self = [super init];
    if (!self) return NULL;
    
    // Setup label
    self.label = [CCLabelTTF labelWithString:title fontName:@"Helvetica" fontSize:12];
    
    _labelColors = [NSMutableDictionary dictionary];
    
    [self setLabelColor:ccc3(127, 127, 127) forState:CCControlStateSelected];
    
    // Setup background image
    if (frameName)
    {
        self.background = [CCSprite9Slice spriteWithSpriteFrameName:frameName];
    }
    else
    {
        self.background = [[CCSprite9Slice alloc] init];
    }
    
    [self addChild:_background z:0];
    [self addChild:_label z:1];
    
    [self needsLayout];
    
    return self;
}

- (void) layout
{
    // Calculate content size
    CGSize size = self.label.contentSize;
    
    _label.position = ccp((int)(size.width/2), ((int)size.height/2));
    
    _contentSize = size;
    
    [super layout];
}

- (void) touchEntered:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.selected = YES;
}

- (void) touchExited:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.selected = NO;
}

- (void) touchUpInside:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self triggerAction];
    self.selected = NO;
}

- (void) touchUpOutside:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.selected = NO;
}

- (void) stateChanged
{
    if (self.selected)
    {
        _label.color = [self labelColorForState:CCControlStateSelected];
        
        [_label runAction:[CCScaleTo actionWithDuration:0.1 scale:1.2]];
    }
    else
    {
        _label.color = [self labelColorForState:CCControlStateNormal];
        
        [_label stopAllActions];
        _label.scale = 1.0;
    }
}

- (void) setLabelColor:(ccColor3B)color forState:(NSUInteger)state
{
    [_labelColors setObject:[NSValue value:&color withObjCType:@encode(ccColor3B)] forKey:[NSNumber numberWithInt:state]];
}

- (ccColor3B) labelColorForState:(NSUInteger)state
{
    NSValue* val = [_labelColors objectForKey:[NSNumber numberWithInt:state]];
    if (!val) return ccc3(255, 255, 255);
    ccColor3B color;
    [val getValue:&color];
    return color;
}

@end
