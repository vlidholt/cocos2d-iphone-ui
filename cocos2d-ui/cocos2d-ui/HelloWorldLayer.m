//
//  HelloWorldLayer.m
//  cocos2d-ui
//
//  Created by Viktor on 9/2/13.
//  Copyright Apportable 2013. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#import "CCControl.h"
#import "CCButton.h"

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
		
		// create and initialize a Label
        
        CCSpriteFrame* frame = [CCSpriteFrame frameWithTextureFilename:@"button.png" rect:CGRectMake(0, 0, 64, 64)];
        
        CCButton* button = [[CCButton alloc] initWithTitle:@"HelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHello" spriteFrame:frame];
        //button.preferredSize = CGSizeMake(200, 100);
        button.horizontalPadding = 15;
        button.verticalPadding = 15;
        button.position = ccp(200, 200);
        //button.enabled = NO;
        [self addChild:button];
        [button setTarget:self selector:@selector(callback:)];
        
        CCButton* button2 = [[CCButton alloc] initWithTitle:@"Hello2" fontName:@"Marker Felt" fontSize:24];
        button2.position = ccp(300, 300);
        [self addChild:button2];
	}
	return self;
}

- (void) callback:(id)sender
{
    NSLog(@"Tapped button");
}

// on "dealloc" you need to release all your retained objects

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}
@end
