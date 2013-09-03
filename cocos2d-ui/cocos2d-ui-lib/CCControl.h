//
//  CCControl.h
//  cocos2d-ui
//
//  Created by Viktor on 9/2/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "CCNode.h"

/** The possible state for a control.  */
enum
{
    CCControlStateNormal       = 1 << 0, // The normal, or default state of a control—that is, enabled but neither selected nor highlighted.
    CCControlStateHighlighted  = 1 << 1, // Highlighted state of a control. A control enters this state when a touch down, drag inside or drag enter is performed. You can retrieve and set this value through the highlighted property.
    CCControlStateDisabled     = 1 << 2, // Disabled state of a control. This state indicates that the control is currently disabled. You can retrieve and set this value through the enabled property.
    CCControlStateSelected     = 1 << 3  // Selected state of a control. This state indicates that the control is currently selected. You can retrieve and set this value through the selected property.
};
typedef NSUInteger CCControlState;

@interface CCControl : CCNode
{
    BOOL _needsLayout;
}

@property (nonatomic,assign) CGSize preferredSize;
@property (nonatomic,assign) CGSize maxSize;

@property (nonatomic,assign) CCControlState state;
@property (nonatomic,assign) BOOL enabled;
@property (nonatomic,assign) BOOL selected;
@property (nonatomic,assign) BOOL highlighted;

@property (nonatomic,assign) BOOL continuous;

@property (nonatomic,readonly) BOOL tracking;
@property (nonatomic,readonly) BOOL touchInside;

@property (nonatomic,copy) void(^block)(id sender);
-(void) setTarget:(id)target selector:(SEL)selector;

- (void) triggerAction;
- (void) stateChanged;

- (void) needsLayout;
- (void) layout;

- (void) touchEntered:(UITouch*) touch withEvent:(UIEvent*)event;
- (void) touchExited:(UITouch*) touch withEvent:(UIEvent*) event;
- (void) touchUpInside:(UITouch*) touch withEvent:(UIEvent*) event;
- (void) touchUpOutside:(UITouch*) touch withEvent:(UIEvent*) event;

@end
