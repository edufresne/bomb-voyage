//
//  MainMenuScene.m
//  Tylers app Revised
//
//  Created by Eric Dufresne on 2014-10-12.
//  Copyright (c) 2014 Eric Dufresne. All rights reserved.
//

#import "MainMenuScene.h"
#import "NewGameScene.h"
#import "AppDelegate.h"
#import "ViewController.h"

@interface MainMenuScene ()
@property BOOL contentCreated;
@end

@implementation MainMenuScene
@synthesize smallButtonAtlas, bigButtonAtlas;

#pragma mark - Initialization Methods

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
    //Creating buttons as well as sending a NSNotification "showAd" which lets the root view controller display ads in the current scene.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showAd" object:nil];
    SKSpriteNode *backGround = [[SKSpriteNode alloc]initWithImageNamed:@"menu background.png"];
    backGround.size = self.size;
    backGround.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:backGround];
    SKSpriteNode *classicButton = [[SKSpriteNode alloc]initWithTexture:[bigButtonAtlas textureNamed:@"play"]];
    classicButton.name = @"classicButton";
    classicButton.size = CGSizeMake(210, 60);
    classicButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+38);
    [self addChild:classicButton];
    
    SKSpriteNode *leaderboardButton = [[SKSpriteNode alloc]initWithTexture:[bigButtonAtlas textureNamed:@"leaderboards"]];
    leaderboardButton.name = @"leaderboardButton";
    leaderboardButton.size = classicButton.size;
    leaderboardButton.position = CGPointMake(classicButton.position.x, classicButton.position.y-leaderboardButton.size.height-10);
    [self addChild:leaderboardButton];
    
    SKSpriteNode *storeButton = [[SKSpriteNode alloc] initWithTexture:[bigButtonAtlas textureNamed:@"store"]];
    storeButton.size = classicButton.size;
    storeButton.name = @"storeButton";
    storeButton.position = CGPointMake(classicButton.position.x, leaderboardButton.position.y-storeButton.size.height-10);
    [self addChild:storeButton];
    
    SKSpriteNode *rateButton = [[SKSpriteNode alloc]initWithTexture:[smallButtonAtlas textureNamed:@"ratebutton"]];
    rateButton.size =CGSizeMake(56,52);
    rateButton.position = CGPointMake(CGRectGetMidX(self.frame)-10-rateButton.size.width/2, CGRectGetMinY(self.frame)+rateButton.size.width/2+self.size.height/11+6);
    rateButton.name = @"rateButton";
    [self addChild:rateButton];
    
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    SKSpriteNode *removeAdsButton = [[SKSpriteNode alloc]initWithTexture:[smallButtonAtlas textureNamed:@"removeads"]];
    removeAdsButton.size = rateButton.size;
    removeAdsButton.position = CGPointMake(rateButton.position.x-removeAdsButton.size.width-20, rateButton.position.y);
    removeAdsButton.name = @"removeAdsButton";
    if (delegate.adsRemoved)
        removeAdsButton.alpha = 0.5;
    [self addChild:removeAdsButton];
    
    SKSpriteNode *facebookButton = [[SKSpriteNode alloc]initWithTexture:[smallButtonAtlas textureNamed:@"facebook"]];
    facebookButton.size = rateButton.size;
    facebookButton.position = CGPointMake(CGRectGetMidX(self.frame)+10+facebookButton.size.width/2, removeAdsButton.position.y);
    facebookButton.name = @"facebookButton";
    [self addChild:facebookButton];
    
    SKSpriteNode *twitterButton = [[SKSpriteNode alloc]initWithTexture:[smallButtonAtlas textureNamed:@"twitter"]];
    twitterButton.size = rateButton.size;
    twitterButton.position = CGPointMake(facebookButton.position.x+twitterButton.size.width+20, facebookButton.position.y);
    twitterButton.name = @"twitterButton";
    [self addChild:twitterButton];
    
    SKSpriteNode *settingsButton = [[SKSpriteNode alloc] initWithTexture:[smallButtonAtlas textureNamed:@"settings.png"]];
    settingsButton.size = CGSizeMake(twitterButton.size.width/1.5, twitterButton.size.height/1.5);
    settingsButton.position = CGPointMake(settingsButton.size.width/2+10, self.size.height-settingsButton.size.height/2-10);
    settingsButton.name = @"settingsButton";
    [self addChild:settingsButton];
}

#pragma mark - Touch Control Methods
//If touches ended on a button the scene will do certain behaviour based on sprites name.
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    SKNode *node = [self nodeAtPoint:[touch locationInNode:self]];
    
    if ([node.name isEqualToString:@"classicButton"])
    {
        //Preloads textures and presents the game scene on completion.
        NSArray *array = [NSArray arrayWithObjects:[SKTextureAtlas atlasNamed:@"man.atlas"], [SKTextureAtlas atlasNamed:@"arrow.atlas"],[SKTextureAtlas atlasNamed:@"items.atlas"], nil];
        [SKTextureAtlas preloadTextureAtlases:array withCompletionHandler:^{
            NewGameScene *gameScene = [[NewGameScene alloc]initWithSize:self.size];
            gameScene.manAtlas = array[0];
            gameScene.arrowAtlas = array[1];
            gameScene.itemAtlas = array[2];
            [self.view presentScene:gameScene transition:[SKTransition fadeWithDuration:3]];
        }];
    }
    else if ([node.name isEqualToString:@"leaderboardButton"])
    {
        //Calls method from root view controller to attempt to bring up leaderboards
        ViewController *viewController = (ViewController*)self.view.window.rootViewController;
        [viewController attemptAuthenticateForLeaderboard];
    }
    else if ([node.name isEqualToString:@"storeButton"])
    {
        //Performs segue to store controller
        ViewController *viewController = (ViewController*)self.view.window.rootViewController;
        [viewController performSegueWithIdentifier:@"storeSegue" sender:viewController];
    }
    else if ([node.name isEqualToString:@"rateButton"])
    {
        //Links to app store page
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/app/id955896287"]];
    }
    else if ([node.name isEqualToString:@"removeAdsButton"])
    {
        //Gets product that was stored in root view controller. Action sheet that has the option to restore the purchase or purchase it.
        AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        ViewController *viewController = (ViewController*)self.view.window.rootViewController;
        if (!delegate.adsRemoved&&viewController.product!=nil)
        {
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Remove Ads?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Purchase", @"Restore", nil];
            [sheet showInView:self.view];
        }
    }
    else if ([node.name isEqualToString:@"twitterButton"])
    {
        //Opens twitter page
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.twitter.com/IndieEndGames"]];
    }
    else if ([node.name isEqualToString:@"facebookButton"])
    {
        //Opens facebook page
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/pages/Indie-End-Games/1393962414244945"]];
    }
    else if ([node.name isEqualToString:@"settingsButton"])
    {
        //Opens settings via segue
        ViewController *rootViewController = (ViewController*)self.view.window.rootViewController;
        [rootViewController performSegueWithIdentifier:@"settingsSegue" sender:rootViewController];
    }
    // Resets buttons to non pressed texture
    SKNode *nodeFind = [self childNodeWithName:@"classicButton"];
    SKAction *changeTexture = [SKAction setTexture:[bigButtonAtlas textureNamed:@"play"]];
    [nodeFind runAction:changeTexture];
    nodeFind = [self childNodeWithName:@"leaderboardButton"];
    changeTexture = [SKAction setTexture:[bigButtonAtlas textureNamed:@"leaderboards"]];
    [nodeFind runAction:changeTexture];
    nodeFind = [self childNodeWithName:@"storeButton"];
    changeTexture = [SKAction setTexture:[bigButtonAtlas textureNamed:@"store"]];
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
    nodeFind = [self childNodeWithName:@"settingsButton"];
    changeTexture = [SKAction setTexture:[smallButtonAtlas textureNamed:@"settings"]];
    [nodeFind runAction:changeTexture];
}
//If button is touched the buttons texutre will change to the pressed version.
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
    else if ([node.name isEqualToString:@"storeButton"])
    {
        SKAction *changeTexture = [SKAction setTexture:[bigButtonAtlas textureNamed:@"store_pressed"]];
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
    else if ([node.name isEqualToString:@"settingsButton"])
    {
        SKAction *changeTexture = [SKAction setTexture:[smallButtonAtlas textureNamed:@"settings_pressed"]];
        [node runAction:changeTexture];
    }
    
}
#pragma mark - Action Sheet Delegate
//Calls IAP methods from ViewController
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    ViewController *viewController = (ViewController*)self.view.window.rootViewController;
    if (buttonIndex == 0)
        [viewController purchaseInAppPurchase];
    else if (buttonIndex == 1)
        [viewController restoreInAppPurchase];
}
@end
