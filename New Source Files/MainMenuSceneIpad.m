//
//  MainMenuScene.m
//  Tylers app Revised
//
//  Created by Eric Dufresne on 2014-10-12.
//  Copyright (c) 2014 Eric Dufresne. All rights reserved.
//

#import "MainMenuSceneIpad.h"
#import "NewGameScene.h"

@interface MainMenuSceneIpad ()
@property BOOL contentCreated;
@end

@implementation MainMenuSceneIpad
@synthesize smallButtonAtlas, bigButtonAtlas;

#pragma mark - Initialization Methods

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        
    }
    return self;
}

-(void)didMoveToView:(SKView *)view
{
    if (!self.contentCreated)
    {
        self.contentCreated = YES;
        [self createSceneContent];
    }
}
-(void)createSceneContent
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showAd" object:nil];
    SKSpriteNode *backGround = [[SKSpriteNode alloc]initWithImageNamed:@"menu background.png"];
    backGround.size = self.size;
    backGround.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:backGround];
    
    SKSpriteNode *classicButton = [[SKSpriteNode alloc]initWithTexture:[bigButtonAtlas textureNamed:@"play"]];
    classicButton.name = @"classicButton";
    classicButton.size = CGSizeMake(420, 120);
    classicButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+20);
    [self addChild:classicButton];
    
    SKSpriteNode *leaderboardButton = [[SKSpriteNode alloc]initWithTexture:[bigButtonAtlas textureNamed:@"leaderboards"]];
    leaderboardButton.name = @"leaderboardButton";
    leaderboardButton.size = classicButton.size;
    leaderboardButton.position = CGPointMake(classicButton.position.x, CGRectGetMidY(self.frame)-leaderboardButton.size.height-20);
    [self addChild:leaderboardButton];
    
    SKSpriteNode *rateButton = [[SKSpriteNode alloc]initWithTexture:[smallButtonAtlas textureNamed:@"ratebutton"]];
    rateButton.size =CGSizeMake(112,104);
    rateButton.position = CGPointMake(CGRectGetMidX(self.frame)-20-rateButton.size.width/2, CGRectGetMinY(self.frame)+rateButton.size.width/2+self.size.height/11+12);
    rateButton.name = @"rateButton";
    [self addChild:rateButton];
    SKSpriteNode *removeAdsButton = [[SKSpriteNode alloc]initWithTexture:[smallButtonAtlas textureNamed:@"removeads"]];
    removeAdsButton.size = rateButton.size;
    removeAdsButton.position = CGPointMake(rateButton.position.x-removeAdsButton.size.width-40, rateButton.position.y);
    removeAdsButton.name = @"removeAdsButton";
    [self addChild:removeAdsButton];
    
    SKSpriteNode *facebookButton = [[SKSpriteNode alloc]initWithTexture:[smallButtonAtlas textureNamed:@"facebook"]];
    facebookButton.size = rateButton.size;
    facebookButton.position = CGPointMake(CGRectGetMidX(self.frame)+20+facebookButton.size.width/2, removeAdsButton.position.y);
    facebookButton.name = @"facebookButton";
    [self addChild:facebookButton];
    
    SKSpriteNode *twitterButton = [[SKSpriteNode alloc]initWithTexture:[smallButtonAtlas textureNamed:@"twitter"]];
    twitterButton.size = rateButton.size;
    twitterButton.position = CGPointMake(facebookButton.position.x+twitterButton.size.width+40, facebookButton.position.y);
    twitterButton.name = @"twitterButton";
    [self addChild:twitterButton];
}

#pragma mark - Touch Control Methods

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    SKNode *node = [self nodeAtPoint:[touch locationInNode:self]];
    
    if ([node.name isEqualToString:@"classicButton"])
    {
        NSArray *array = [NSArray arrayWithObjects:[SKTextureAtlas atlasNamed:@"man.atlas"], [SKTextureAtlas atlasNamed:@"arrow.atlas"], [SKTextureAtlas atlasNamed:@"bigNum.atlas"], [SKTextureAtlas atlasNamed:@"smallNum.atlas"], nil];
        [SKTextureAtlas preloadTextureAtlases:array withCompletionHandler:^{
            NewGameScene *gameScene = [[NewGameScene alloc]initWithSize:self.size];
            gameScene.manAtlas = array[0];
            gameScene.arrowAtlas = array[1];
            gameScene.bigNumAtlas = array[2];
            gameScene.smallNumAtlas = array[3];
            [self.view presentScene:gameScene transition:[SKTransition fadeWithDuration:3]];
        }];
        /*
         NewGameScene *gameScene = [[NewGameScene alloc]initWithSize:self.size];
         gameScene.manAtlas = [SKTextureAtlas atlasNamed:@"man"];
         gameScene.arrowAtlas = [SKTextureAtlas atlasNamed:@"arrow"];
         gameScene.bigNumAtlas = [SKTextureAtlas atlasNamed:@"bigNum"];
         gameScene.smallNumAtlas = [SKTextureAtlas atlasNamed:@"smallNum"];
         [self.view presentScene:gameScene transition:[SKTransition fadeWithDuration:2]];
         */
    }
    else if ([node.name isEqualToString:@"leaderboardButton"])
    {
        BOOL leaderBoardSignedIn = NO;
        if (!leaderBoardSignedIn)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Game Center Not Signed In" message:@"Go to Game Center?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
            [alertView show];
        }
    }
    else if ([node.name isEqualToString:@"rateButton"])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.apple.com"]];
    }
    else if ([node.name isEqualToString:@"removeAdsButton"])
    {
        // Queue in app purchase //
    }
    else if ([node.name isEqualToString:@"twitterButton"])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.twitter.com"]];
    }
    else if ([node.name isEqualToString:@"facebookButton"])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.facebook.com"]];
    }
    else
    {
        SKNode *nodeFind = [self childNodeWithName:@"classicButton"];
        SKAction *changeTexture = [SKAction setTexture:[bigButtonAtlas textureNamed:@"play"]];
        [nodeFind runAction:changeTexture];
        nodeFind = [self childNodeWithName:@"leaderboardButton"];
        changeTexture = [SKAction setTexture:[bigButtonAtlas textureNamed:@"leaderboards"]];
        [nodeFind runAction:changeTexture];
        nodeFind = [self childNodeWithName:@"rateButton"];
        changeTexture = [SKAction setTexture:[smallButtonAtlas textureNamed:@"ratebutton"]];
        [nodeFind runAction:changeTexture];
        nodeFind = [self childNodeWithName:@"removeAdsButton"];
        changeTexture = [SKAction setTexture:[smallButtonAtlas textureNamed:@"removeads"]];
        [nodeFind runAction:changeTexture];
        nodeFind = [self childNodeWithName:@"facebookButton"];
        changeTexture = [SKAction setTexture:[smallButtonAtlas textureNamed:@"facebook"]];
        [nodeFind runAction:changeTexture];
        nodeFind = [self childNodeWithName:@"twitterButton"];
        changeTexture = [SKAction setTexture:[smallButtonAtlas textureNamed:@"twitter"]];
        [nodeFind runAction:changeTexture];
    }
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    SKNode *node = [self nodeAtPoint:[touch locationInNode:self]];
    
    if ([node.name isEqualToString:@"classicButton"])
    {
        SKAction *changeTexture = [SKAction setTexture:[bigButtonAtlas textureNamed:@"play_pressed"]];
        [node runAction:changeTexture];
    }
    else if ([node.name isEqualToString:@"leaderboardButton"])
    {
        SKAction *changeTexture = [SKAction setTexture:[bigButtonAtlas textureNamed:@"leaderboards_pressed"]];
        [node runAction:changeTexture];
    }
    else if ([node.name isEqualToString:@"rateButton"])
    {
        SKAction *changeTexture = [SKAction setTexture:[smallButtonAtlas textureNamed:@"ratebuttonpressed"]];
        [node runAction:changeTexture];
    }
    else if ([node.name isEqualToString:@"removeAdsButton"])
    {
        SKAction *changeTexture = [SKAction setTexture:[smallButtonAtlas textureNamed:@"removeadspressed"]];
        [node runAction:changeTexture];
    }
    else if ([node.name isEqualToString:@"twitterButton"])
    {
        SKAction *changeTexture = [SKAction setTexture:[smallButtonAtlas textureNamed:@"twitterpressed"]];
        [node runAction:changeTexture];
    }
    else if ([node.name isEqualToString:@"facebookButton"])
    {
        SKAction *changeTexture = [SKAction setTexture:[smallButtonAtlas textureNamed:@"facebookpressed"]];
        [node runAction:changeTexture];
    }
    
}

#pragma mark - AlertView Delegate Method

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"GameCenter:"]];
    }
}

@end
