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
#import "CCScrollView.h"

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
        int numPages = 4;
        
        CCNode* content = [CCNode node];
        content.contentSize = CGSizeMake(1024 * numPages, 768);
        for (int i = 0; i < numPages; i++)
        {
            CCButton* btn = [CCButton buttonWithTitle:[NSString stringWithFormat:@"%d",i] fontName:@"Marker Felt" fontSize:200];
            btn.position = ccp(1024*i + 512, 384);
            btn.anchorPoint = ccp(0.5, 0.5);
            [content addChild:btn];
        }
        
        CCScrollView* scroll = [[CCScrollView alloc] initWithContentNode:content contentSize:CGSizeMake(1024, 768)];
        scroll.verticalScrollEnabled = NO;
        [self addChild:scroll];
        
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
