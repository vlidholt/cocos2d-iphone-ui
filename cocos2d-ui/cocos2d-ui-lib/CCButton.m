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

#import "CCButton.h"

@implementation CCButton

- (id) init
{
    return [self initWithTitle:@"" spriteFrame:NULL];
}

+ (id) buttonWithTitle:(NSString*) title
{
    return [[self alloc] initWithTitle:title];
}

+ (id) buttonWithTitle:(NSString*) title fontName:(NSString*)fontName fontSize:(float)size
{
    return [[self alloc] initWithTitle:title fontName:fontName fontSize:size];
}

+ (id) buttonWithTitle:(NSString*) title spriteFrame:(CCSpriteFrame*) spriteFrame
{
    return [[self alloc] initWithTitle:title spriteFrame:spriteFrame];
}

+ (id) buttonWithTitle:(NSString*) title spriteFrame:(CCSpriteFrame*) spriteFrame highlightedSpriteFrame:(CCSpriteFrame*) highlighted disabledSpriteFrame:(CCSpriteFrame*) disabled
{
    return [[self alloc] initWithTitle:title spriteFrame:spriteFrame highlightedSpriteFrame: highlighted disabledSpriteFrame:disabled];
}

- (id) initWithTitle:(NSString *)title
{
    self = [self initWithTitle:title spriteFrame:NULL highlightedSpriteFrame:NULL disabledSpriteFrame:NULL];
    
    // Default properties for labels with only a title
    self.zoomWhenHighlighted = YES;
    
    return self;
}

- (id) initWithTitle:(NSString *)title fontName:(NSString*)fontName fontSize:(float)size
{
    self = [self initWithTitle:title];
    self.label.fontName = fontName;
    self.label.fontSize = size;
    return self;
}

- (id) initWithTitle:(NSString*) title spriteFrame:(CCSpriteFrame*) spriteFrame
{
    self = [self initWithTitle:title spriteFrame:spriteFrame highlightedSpriteFrame:NULL disabledSpriteFrame:NULL];
    
    // Setup default colors for when only one frame is used
    [self setBackgroundColor:ccc3(190, 190, 190) forState:CCControlStateHighlighted];
    [self setLabelColor:ccc3(190, 190, 190) forState:CCControlStateHighlighted];
    
    [self setBackgroundOpacity:127 forState:CCControlStateDisabled];
    [self setLabelOpacity:127 forState:CCControlStateDisabled];
    
    return self;
}

- (id) initWithTitle:(NSString*) title spriteFrame:(CCSpriteFrame*) spriteFrame highlightedSpriteFrame:(CCSpriteFrame*) highlighted disabledSpriteFrame:(CCSpriteFrame*) disabled
{
    self = [super init];
    if (!self) return NULL;
    
    if (!title) title = @"";
    
    // Setup holders for properties
    _backgroundColors = [NSMutableDictionary dictionary];
    _backgroundOpacities = [NSMutableDictionary dictionary];
    _backgroundSpriteFrames = [NSMutableDictionary dictionary];
    
    _labelColors = [NSMutableDictionary dictionary];
    _labelOpacities = [NSMutableDictionary dictionary];
    
    // Setup background image
    if (spriteFrame)
    {
        _background = [CCSprite9Slice spriteWithSpriteFrame:spriteFrame];
        [self setBackgroundSpriteFrame:spriteFrame forState:CCControlStateNormal];
    }
    else
    {
        _background = [[CCSprite9Slice alloc] init];
    }
    
    [self addChild:_background z:0];
    
    // Setup label
    _label = [CCLabelTTF labelWithString:title fontName:@"Helvetica" fontSize:14];
    
    [self addChild:_label z:1];
    
    // Setup original scale
    _originalScaleX = _originalScaleY = 1;
    
    [self needsLayout];
    [self stateChanged];
    
    return self;
}

- (void) layout
{
    CGSize paddedLabelSize = _label.contentSize;
    paddedLabelSize.width += _horizontalPadding * 2;
    paddedLabelSize.height += _verticalPadding * 2;
    
    CGSize size = paddedLabelSize;
    
    BOOL shrunkSize = NO;
    size = self.preferredSize;
    
    if (size.width < paddedLabelSize.width) size.width = paddedLabelSize.width;
    if (size.height < paddedLabelSize.height) size.height = paddedLabelSize.height;
    
    if (self.maxSize.width > 0 && self.maxSize.width < size.width)
    {
        size.width = self.maxSize.width;
        shrunkSize = YES;
    }
    if (self.maxSize.height > 0 && self.maxSize.height < size.height)
    {
        size.height = self.maxSize.height;
        shrunkSize = YES;
    }
    
    if (shrunkSize)
    {
        // TODO: Shrink Label
    }
    
    _background.contentSize = size;
    _background.anchorPoint = ccp(0,0);
    _background.position = ccp(0,0);
    _label.position = ccp((int)(size.width/2), ((int)size.height/2));
    
    self.contentSize = size;
    
    [super layout];
}

- (void) touchEntered:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.highlighted = YES;
}

- (void) touchExited:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.highlighted = NO;
}

- (void) touchUpInside:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self triggerAction];
    self.highlighted = NO;
}

- (void) touchUpOutside:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.highlighted = NO;
}

- (void) updatePropertiesForState:(NSUInteger)state
{
    // Update background
    _background.color = [self backgroundColorForState:state];
    _background.opacity = [self backgroundOpacityForState:state];
    
    CCSpriteFrame* spriteFrame = [self backgroundSpriteFrameForState:state];
    if (!spriteFrame) spriteFrame = [self backgroundSpriteFrameForState:CCControlStateNormal];
    [_background setDisplayFrame:spriteFrame];
    
    // Update label
    _label.color = [self labelColorForState:state];
    _label.opacity = [self labelOpacityForState:state];
    
    [self needsLayout];
}

- (void) stateChanged
{
    if (self.enabled)
    {
        // Button is enabled
        if (self.highlighted)
        {
            [self updatePropertiesForState:CCControlStateHighlighted];
            
            if (_zoomWhenHighlighted)
            {
                [_label runAction:[CCScaleTo actionWithDuration:0.1 scaleX:_originalScaleX*1.2 scaleY:_originalScaleY*1.2]];
            }
        }
        else
        {
            [self updatePropertiesForState:CCControlStateNormal];
            
            [_label stopAllActions];
            if (_zoomWhenHighlighted)
            {
                _label.scaleX = _originalScaleX;
                _label.scaleY = _originalScaleY;
            }
        }
    }
    else
    {
        // Button is disabled
        [self updatePropertiesForState:CCControlStateDisabled];
    }
}

#pragma mark Properties

- (void) setScale:(float)scale
{
    _originalScaleX = _originalScaleY = scale;
    [super setScale:scale];
}

- (void) setScaleX:(float)scaleX
{
    _originalScaleX = scaleX;
    [super setScaleX:scaleX];
}

- (void) setScaleY:(float)scaleY
{
    _originalScaleY = scaleY;
    [super setScaleY:scaleY];
}

- (void) setLabelColor:(ccColor3B)color forState:(CCControlState)state
{
    [_labelColors setObject:[NSValue value:&color withObjCType:@encode(ccColor3B)] forKey:[NSNumber numberWithInt:state]];
    [self stateChanged];
}

- (ccColor3B) labelColorForState:(CCControlState)state
{
    NSValue* val = [_labelColors objectForKey:[NSNumber numberWithInt:state]];
    if (!val) return ccc3(255, 255, 255);
    ccColor3B color;
    [val getValue:&color];
    return color;
}

- (void) setLabelOpacity:(GLubyte)opacity forState:(CCControlState)state
{
    [_labelOpacities setObject:[NSNumber numberWithInt:opacity] forKey:[NSNumber numberWithInt:state]];
    [self stateChanged];
}

- (GLubyte) labelOpacityForState:(CCControlState)state
{
    NSNumber* val = [_labelOpacities objectForKey:[NSNumber numberWithInt:state]];
    if (!val) return 255;
    return [val intValue];
}

- (void) setBackgroundColor:(ccColor3B)color forState:(CCControlState)state
{
    [_backgroundColors setObject:[NSValue value:&color withObjCType:@encode(ccColor3B)] forKey:[NSNumber numberWithInt:state]];
    [self stateChanged];
}

- (ccColor3B) backgroundColorForState:(CCControlState)state
{
    NSValue* val = [_backgroundColors objectForKey:[NSNumber numberWithInt:state]];
    if (!val) return ccc3(255, 255, 255);
    ccColor3B color;
    [val getValue:&color];
    return color;
}

- (void) setBackgroundOpacity:(GLubyte)opacity forState:(CCControlState)state
{
    [_backgroundOpacities setObject:[NSNumber numberWithInt:opacity] forKey:[NSNumber numberWithInt:state]];
    [self stateChanged];
}

- (GLubyte) backgroundOpacityForState:(CCControlState)state
{
    NSNumber* val = [_backgroundOpacities objectForKey:[NSNumber numberWithInt:state]];
    if (!val) return 255;
    return [val intValue];
}

- (void) setBackgroundSpriteFrame:(CCSpriteFrame*)spriteFrame forState:(CCControlState)state
{
    if (spriteFrame)
    {
        [_backgroundSpriteFrames setObject:spriteFrame forKey:[NSNumber numberWithInt:state]];
    }
    else
    {
        [_backgroundSpriteFrames removeObjectForKey:[NSNumber numberWithInt:state]];
    }
    [self stateChanged];
}

- (CCSpriteFrame*) backgroundSpriteFrameForState:(CCControlState)state
{
    return [_backgroundSpriteFrames objectForKey:[NSNumber numberWithInt:state]];
}

@end
