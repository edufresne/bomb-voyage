//
//  GameScene.m
//  Tylers app Revised
//
//  Created by Eric Dufresne on 2014-10-07.
//  Copyright (c) 2014 Eric Dufresne. All rights reserved.
//
//  -- Start of Code --

//  Preprocessor import and define statements
#import "NewGameSceneIpad.h"
#import "Digit.h"
#import "MainMenuScene.h"
#import "Man.h"
#import "Arrow.h"

#define rowStartYHeight 100
#define fallInterval -8
#define fallDuration 0.025
#define counterBuffer 2
#define bombDelay 0.5

//  Private Scene Variables
@interface NewGameSceneIpad ()
{
    Arrow *leftArrow;
    Arrow *rightArrow;
    Man *man;
    SKSpriteNode *background;
    SKAction *coinSound;
    
    NSInteger numberOfEvents;
    
    SKTexture *coinTexture;
    SKTexture *bombTexture;
    CGFloat yposCoin;
    CGFloat yposBomb;
    CGFloat xpos1;
    CGFloat xpos2;
    CGFloat xpos3;
    
}
@property BOOL contentCreated;
@property BOOL gameStarted;
@property BOOL menuShowing;
@property (strong, nonatomic) NSNumber *highScore;
@end

//  Start Of Implementation
@implementation NewGameSceneIpad
@synthesize coinsCollected, bigNumAtlas, smallNumAtlas, arrowAtlas, manAtlas;

// Category 32 bit masks for physics contact and collision. Shifted so all bits are out of place //
static const uint32_t manCategory = 0x1 << 0;
static const uint32_t coinCategory = 0x1 << 1;
static const uint32_t bombCategory = 0x1 << 2;

// Event parameters that are variable to numberOfEvents //
static double eventGenDelay = 1.5;
static int eventMin = 10;
static int eventMax = 25;
static double timeInBetweenEvents = 0;

#pragma mark - Initialization

//Initialization method that creates initial gravity force, initializes reused textures for generated objects and positions for generated objects //
-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        self.physicsWorld.contactDelegate = self;
        coinTexture = [SKTexture textureWithImageNamed:@"coin w21 h21.png"];
        bombTexture = [SKTexture textureWithImageNamed:@"bigbomb1.png"];
        
        yposCoin = CGRectGetMaxY(self.frame)+52;
        yposBomb = CGRectGetMaxY(self.frame)+86;
        xpos1 = CGRectGetMinX(self.frame)+92;
        xpos2 = CGRectGetMidX(self.frame);
        xpos3 = CGRectGetMaxX(self.frame)-92;
    }
    return self;
}
// Called when SKView is presented by root View controller. Initializes sound, loads previous high score and creates initial scene content //
-(void)didMoveToView:(SKView *)view
{
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
    
    coinSound = [SKAction playSoundFileNamed:@"coinsound.mp3" waitForCompletion:NO];
    // });
    
    if (!self.contentCreated)
    {
        self.highScore = [[NSUserDefaults standardUserDefaults]objectForKey:@"highScore"];
        
        if (self.highScore==nil)
            self.highScore = [[NSNumber alloc]initWithInteger:0];
        
        [self createSceneContent];
        self.contentCreated=YES;
        self.backgroundColor = [SKColor whiteColor];
    }
}

#pragma mark - Scene Creation

// Implementation to create scene content at the start of when the scene is presented or when the game is reset. Creates and places all starting nodes in the view and shows tap to press to start the game
-(void)createSceneContent
{
    self.physicsWorld.gravity = CGVectorMake(0, -9.8);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showAd" object:nil];
    
    background = [[SKSpriteNode alloc] initWithImageNamed:@"background.png"];
    background.size = CGSizeMake(CGRectGetMaxX(self.frame), CGRectGetMaxY(self.frame));
    background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    background.zPosition = 0;
    [self addChild:background];
    SKSpriteNode *bluebar = [[SKSpriteNode alloc]initWithImageNamed:@"bluebar.png"];
    bluebar.size = CGSizeMake(CGRectGetMaxX(self.frame), 180);
    CGPoint pos = CGPointMake(CGRectGetMidX(self.frame), bluebar.size.height/2);
    bluebar.position=pos;
    bluebar.zPosition=2;
    bluebar.name = @"bluebar";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        Digit *tensNode = [[Digit alloc] initWIthBigNumbers:YES withAlpha:0 withTextureAtlas:bigNumAtlas];
        tensNode.name = @"tens Node";
        tensNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(bluebar.frame));
        tensNode.zPosition=3;
        [self addChild:tensNode];
        Digit *onesNode = [[Digit alloc]initWIthBigNumbers:YES withAlpha:0 withTextureAtlas:bigNumAtlas];
        onesNode.position = CGPointMake(tensNode.position.x+onesNode.size.width+counterBuffer, tensNode.position.y);
        onesNode.name = @"ones Node";
        onesNode.zPosition=3;
        [self addChild:onesNode];
        Digit *hundredsNode = [[Digit alloc]initWIthBigNumbers:YES withAlpha:0 withTextureAtlas:bigNumAtlas];
        hundredsNode.position = CGPointMake(tensNode.position.x-hundredsNode.size.width-counterBuffer, tensNode.position.y);
        hundredsNode.name = @"hundreds Node";
        hundredsNode.zPosition=3;
        [self addChild:hundredsNode];
    });
    
    
    [self addChild:bluebar];
    leftArrow = [[Arrow alloc]initLeftArrowWithPosition:CGPointMake(100, CGRectGetMidY(bluebar.frame)+4) withTextureAtlas:arrowAtlas];
    leftArrow.name = @"leftArrow";
    leftArrow.zPosition=3;
    [self addChild:leftArrow];
    rightArrow = [[Arrow alloc]initRightArrowWithPosition:CGPointMake( CGRectGetMaxX(bluebar.frame)-100,leftArrow.position.y)withTextureAtlas:arrowAtlas];
    rightArrow.name = @"rightArrow";
    rightArrow.zPosition=3;
    [self addChild:rightArrow];
    man = [[Man alloc] initWithBeastMode:NO withTextureAtlas:manAtlas];
    man.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMaxY(bluebar.frame)+man.size.width/2-6);
    man.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(man.size.width/10, man.size.height/2) center:CGPointMake(0, -man.size.height/4)];
    man.physicsBody.categoryBitMask = manCategory;
    man.physicsBody.collisionBitMask = 0x0;
    man.physicsBody.contactTestBitMask = 0x0;
    man.physicsBody.dynamic = NO;
    [self addChild:man];
    [self showTapButton];
}
//  Implementation of method called after the game has ended. Brings up menu with high score and current score plus options on what to do next. Also shows iAd banner and shows post game menu and score
-(void)createDeadSceneContent
{
    [background runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"dead screen.png"]]];
    [self addChild:background];
    
    
    SKSpriteNode *bluebar = [[SKSpriteNode alloc]initWithImageNamed:@"bluebar.png"];
    bluebar.size = CGSizeMake(CGRectGetMaxX(self.frame), 180);
    CGPoint pos = CGPointMake(CGRectGetMidX(self.frame), bluebar.size.height/2);
    bluebar.position=pos;
    bluebar.zPosition=2;
    bluebar.name = @"bluebar";
    [self addChild:bluebar];
    
    [leftArrow reset];
    [rightArrow reset];
    [self addChild:leftArrow];
    [self addChild:rightArrow];
    
    man.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(bluebar.frame)+man.size.height/2);
    [man kill];
    [self addChild:man];
    
    SKSpriteNode *deadmenu = [[SKSpriteNode alloc] initWithImageNamed:@"game over classic.png"];
    deadmenu.size = CGSizeMake(600, 410);
    deadmenu.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMaxY(self.frame)-deadmenu.size.height/2-90);
    [self addChild:deadmenu];
    SKSpriteNode *mainMenuButton = [[SKSpriteNode alloc]initWithImageNamed:@"main menu button.png"];
    mainMenuButton.size = CGSizeMake(206, 146);
    mainMenuButton.position = CGPointMake(-134, -70);
    mainMenuButton.name = @"mainMenuButton";
    [deadmenu addChild:mainMenuButton];
    SKSpriteNode *replayButton = [[SKSpriteNode alloc]initWithImageNamed:@"replay button.png"];
    replayButton.size = CGSizeMake(214,146);
    replayButton.position = CGPointMake(134,-70);
    replayButton.name = @"replayButton";
    [deadmenu addChild:replayButton];
    Digit *onesScore = [[Digit alloc] initWIthBigNumbers:NO withAlpha:1 withTextureAtlas:smallNumAtlas];
    Digit *tensScore = [[Digit alloc] initWIthBigNumbers:NO withAlpha:1 withTextureAtlas:smallNumAtlas];
    Digit *hundredsScore = [[Digit alloc]initWIthBigNumbers:NO withAlpha:1 withTextureAtlas:smallNumAtlas];
    [onesScore setScore:self.highScore.intValue%10];
    [tensScore setScore:self.highScore.intValue%100/10];
    [hundredsScore setScore:self.highScore.intValue/100];
    tensScore.position = CGPointMake(0, 110);
    onesScore.position = CGPointMake(tensScore.position.x+onesScore.size.width+4, 110);
    hundredsScore.position = CGPointMake(tensScore.position.x-hundredsScore.size.width-4, 110);
    [replayButton addChild:tensScore];
    [replayButton addChild:onesScore];
    [replayButton addChild:hundredsScore];
    onesScore = [[Digit alloc] initWIthBigNumbers:NO withAlpha:1 withTextureAtlas:smallNumAtlas];
    tensScore = [[Digit alloc]initWIthBigNumbers:NO withAlpha:1 withTextureAtlas:smallNumAtlas];
    hundredsScore = [[Digit alloc]initWIthBigNumbers:NO withAlpha:1 withTextureAtlas:smallNumAtlas];
    [onesScore setScore:coinsCollected%10];
    [tensScore setScore:coinsCollected%100/10];
    [hundredsScore setScore:coinsCollected/100];
    tensScore.position = CGPointMake(0, 110);
    onesScore.position = CGPointMake(tensScore.position.x+onesScore.size.width+4, 110);
    hundredsScore.position = CGPointMake(tensScore.position.x-hundredsScore.size.width-4, 110);
    [mainMenuButton addChild:tensScore];
    [mainMenuButton addChild:onesScore];
    [mainMenuButton addChild:hundredsScore];
    
    [self runAction:[SKAction sequence:@[[SKAction waitForDuration:2.5], [SKAction runBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showAd" object:nil];
    }]]]];
}

#pragma mark SK Methods

//SKPhysicsContact delegate method that is called whenever the logic OR of two contacting category bitmasks intersect. Ends game if player comes in contact with bomb or removes coin, adds it to the score and then in a background thread increments the counter //
-(void)didBeginContact:(SKPhysicsContact *)contact
{
    if (contact.bodyA.categoryBitMask == bombCategory || contact.bodyB.categoryBitMask == bombCategory)
    {
        [self endGame];
    }
    else if (contact.bodyA.categoryBitMask == coinCategory || contact.bodyB.categoryBitMask == coinCategory)
    {
        if (contact.bodyA.categoryBitMask == coinCategory)
            [contact.bodyA.node removeFromParent];
        else
            [contact.bodyB.node removeFromParent];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            coinsCollected++;
            
            [self runAction:coinSound];
            [man expandBag];
            
            Digit *onesNode = (Digit*)[self childNodeWithName:@"ones Node"];
            Digit *tensNode = (Digit*)[self childNodeWithName:@"tens Node"];
            Digit *hundredsNode = (Digit*)[self childNodeWithName:@"hundreds Node"];
            if (![onesNode increment])
            {
                [onesNode reset];
                if (![tensNode increment])
                {
                    [tensNode reset];
                    [hundredsNode increment];
                }
            }
        });
    }
}

#pragma mark - Game Control

//  Method called at the start of the scene to prompt user to tap screen to start
-(void)showTapButton
{
    SKSpriteNode *tapButton = [[SKSpriteNode alloc]initWithImageNamed:@"tap to start.png"];
    tapButton.size = CGSizeMake(600, 320);
    tapButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+40);
    tapButton.name = @"tapButton";
    [self addChild:tapButton];
}
// Removes all actions and nodes from the scene and causes flash animation. Calls createDeadSceneContent to recreate the scene and show the post game menu in background thread //
-(void)endGame
{
    self.gameStarted=NO;
    self.menuShowing=YES;
    [self removeAllActions];
    [self removeAllChildren];
    
    SKSpriteNode *flash = [[SKSpriteNode alloc] initWithColor:[UIColor whiteColor] size:self.frame.size];
    flash.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    flash.zPosition = 4;
    SKAction *blackAndWhite = [SKAction sequence:@[
                                                   [SKAction waitForDuration:0.075],
                                                   [SKAction colorizeWithColor:[SKColor blackColor] colorBlendFactor:1 duration:0],
                                                   [SKAction waitForDuration:0.075],
                                                   [SKAction colorizeWithColor:[SKColor whiteColor] colorBlendFactor:1 duration:0]
                                                   ]];
    SKAction *action = [SKAction group:@[[SKAction playSoundFileNamed:@"explosion.mp3" waitForCompletion:NO],[SKAction sequence:@[[SKAction repeatAction:blackAndWhite count:6], [SKAction waitForDuration:0.4], [SKAction fadeAlphaTo:0 duration:1], [SKAction removeFromParent]]]]];
    [flash runAction:action];
    [self addChild:flash];
    
    if (coinsCollected>self.highScore.integerValue)
    {
        self.highScore = [NSNumber numberWithInteger:coinsCollected];
        [[NSUserDefaults standardUserDefaults]setObject:self.highScore forKey:@"highScore"];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self createDeadSceneContent];
    });
    
}
// Called if the replay button is called when the menu is showing. Calls createSceneContent and removes iAd
-(void)restartAndSaveGame
{
    coinsCollected = 0;
    [self removeAllChildren];
    [self removeAllActions];
    
    self.menuShowing = NO;
    self.gameStarted = NO;
    [self createSceneContent];
}

#pragma mark - Node Generation and Arithmetic

//Called when the first tap on the screen is created and also calls itself upon completion. This method will reoccur until the game is ended with a delay in between each. Generates a random amount of events to generate based on the calculated max and min values and timeInBetweenEvents parameters //
-(void)generateSetOfEvents
{
    [self updateEventParemeters];
    int eventRand = eventMin + arc4random()%(eventMax - eventMin+1);
    SKAction *action = [SKAction repeatAction:[SKAction sequence:@[[SKAction performSelector:@selector(generateEvent) onTarget:self],[SKAction waitForDuration:timeInBetweenEvents]]] count:eventRand];
    
    SKAction *sequence = [SKAction sequence:@[action, [SKAction runBlock:^{
        
        SKAction *waitThenGenerate = [SKAction sequence:@[[SKAction waitForDuration:eventGenDelay], [SKAction performSelector:@selector(generateSetOfEvents) onTarget:self]]];
        [self runAction:waitThenGenerate withKey:@"GenSets"];
    }]]];
    
    [self runAction:sequence withKey:@"GenEvents"];
    
    numberOfEvents++;
}
//Method that arithmetically calculates min and max number of events plus the time inbetween events. Also increments the gravity. All of these parameters are dependant on numberOfEvents. Also in between sets of events this method will enumerate through all bomb and coin nodes and delete any off screen to free memory //
-(void)updateEventParemeters
{
    eventMin = 2*(int)numberOfEvents+1;
    eventMax = 4.5*(int)numberOfEvents+2;
    timeInBetweenEvents = pow(2.5, -numberOfEvents)+0.35;
    
    if (self.physicsWorld.gravity.dy>-19)
        self.physicsWorld.gravity = CGVectorMake(0, -(9.8+0.90*numberOfEvents));
    
    [self enumerateChildNodesWithName:@"bomb" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.y<0)
            [node runAction:[SKAction removeFromParent]];
    }];
    [self enumerateChildNodesWithName:@"coin" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.y<0)
            [node runAction:[SKAction removeFromParent]];
    }];
}
// MAIN generation algorithm. This generates a number between 0 - 1, each of the speicific types of events have their own probability 0 < p < 1 of that type of event happening. Then once a certain type of event is created a type specific event is then generated (coin position, blank position, bomb position) these are then created at the top of the screen and fall towards the player //
-(void)generateEvent
{
    float r = randomNumber(1, 0);
    if (r<0.2)
    {
        int r2 = arc4random()%3;
        SKSpriteNode *bomb = [[SKSpriteNode alloc] initWithTexture:bombTexture];
        bomb.size = CGSizeMake(110, 172);
        bomb.name = @"bomb";
        bomb.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(bomb.size.width, bomb.size.height/2) center:CGPointMake(0, -bomb.size.height/4)];
        bomb.physicsBody.dynamic = YES;
        bomb.physicsBody.categoryBitMask = bombCategory;
        bomb.physicsBody.contactTestBitMask = manCategory;
        bomb.physicsBody.collisionBitMask = 0x0;
        [bomb runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction waitForDuration:0.1], [SKAction setTexture:[SKTexture textureWithImageNamed:@"bigbomb2"]], [SKAction waitForDuration:0.1],[SKAction setTexture:bombTexture]]]]];
        if (r2 == 0)
            bomb.position = CGPointMake(xpos1, yposBomb);
        else if (r2 == 1)
            bomb.position = CGPointMake(xpos2, yposBomb);
        else
            bomb.position = CGPointMake(xpos3, yposBomb);
        [self addChild:bomb];
    }
    else if (r<0.4)
    {
        int r2 = arc4random()%3;
        SKSpriteNode *coin = [[SKSpriteNode alloc] initWithTexture:coinTexture];
        coin.size = CGSizeMake(110, 110);
        coin.name = @"coin";
        coin.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:coin.size];
        coin.physicsBody.categoryBitMask = coinCategory;
        coin.physicsBody.collisionBitMask = 0x0;
        coin.physicsBody.contactTestBitMask = manCategory;
        if (r2 == 0)
            coin.position = CGPointMake(xpos1, yposCoin);
        else if (r2 == 1)
            coin.position = CGPointMake(xpos2, yposCoin);
        else
            coin.position = CGPointMake(xpos3, yposCoin);
        [self addChild:coin];
    }
    else if (r < 0.6)
    {
        int r2 = arc4random()%3;
        SKSpriteNode *coin = [[SKSpriteNode alloc] initWithTexture:coinTexture];
        coin.size = CGSizeMake(110, 110);
        coin.name = @"coin";
        coin.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:coin.size];
        coin.physicsBody.categoryBitMask = coinCategory;
        coin.physicsBody.collisionBitMask = 0x0;
        coin.physicsBody.contactTestBitMask = manCategory;
        
        SKSpriteNode *bomb = [[SKSpriteNode alloc] initWithTexture:bombTexture];
        bomb.size = CGSizeMake(110, 172);
        bomb.name = @"bomb";
        bomb.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(bomb.size.width, bomb.size.height/2) center:CGPointMake(0, -bomb.size.height/4)];
        bomb.physicsBody.dynamic = YES;
        bomb.physicsBody.categoryBitMask = bombCategory;
        bomb.physicsBody.contactTestBitMask = manCategory;
        bomb.physicsBody.collisionBitMask = 0x0;
        [bomb runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction waitForDuration:0.1], [SKAction setTexture:[SKTexture textureWithImageNamed:@"bigbomb2"]], [SKAction waitForDuration:0.1],[SKAction setTexture:bombTexture]]]]];
        if (r2 == 0)
        {
            coin.position = CGPointMake(xpos1, yposCoin);
            bomb.position = CGPointMake(xpos2, yposBomb);
        }
        else if (r2 == 1)
        {
            coin.position = CGPointMake(xpos1, yposCoin);
            bomb.position = CGPointMake(xpos3, yposBomb);
        }
        else if (r2 == 2)
        {
            coin.position = CGPointMake(xpos2, yposCoin);
            bomb.position = CGPointMake(xpos3, yposBomb);
        }
        else if (r2 == 3)
        {
            bomb.position = CGPointMake(xpos1, yposBomb);
            coin.position = CGPointMake(xpos2, yposCoin);
        }
        else if (r2 == 4)
        {
            bomb.position = CGPointMake(xpos1, yposBomb);
            coin.position = CGPointMake(xpos3, yposCoin);
        }
        else
        {
            bomb.position = CGPointMake(xpos2, yposBomb);
            coin.position = CGPointMake(xpos3, yposBomb);
        }
        [self addChild:bomb];
        [self addChild:coin];
    }
    else if (r <0.8)
    {
        int r2 = arc4random()%3;
        SKSpriteNode *bomb = [[SKSpriteNode alloc] initWithTexture:bombTexture];
        bomb.name = @"bomb";
        bomb.size = CGSizeMake(110, 192);
        bomb.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(bomb.size.width, bomb.size.height/2) center:CGPointMake(0, -bomb.size.height/4)];
        bomb.physicsBody.categoryBitMask = bombCategory;
        bomb.physicsBody.dynamic = YES;
        bomb.physicsBody.contactTestBitMask = manCategory;
        bomb.physicsBody.collisionBitMask = 0x0;
        [bomb runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction waitForDuration:0.1], [SKAction setTexture:[SKTexture textureWithImageNamed:@"bigbomb2"]], [SKAction waitForDuration:0.1],[SKAction setTexture:bombTexture]]]]];
        
        SKSpriteNode *bomb2 = [[SKSpriteNode alloc] initWithTexture:bombTexture];
        bomb2.name = @"bomb";
        bomb2.size = CGSizeMake(110, 192);
        bomb2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(bomb.size.width, bomb.size.height/2) center:CGPointMake(0, -bomb.size.height/4)];
        bomb2.physicsBody.categoryBitMask = bombCategory;
        bomb2.physicsBody.dynamic = YES;
        bomb2.physicsBody.contactTestBitMask = manCategory;
        bomb2.physicsBody.collisionBitMask = 0x0;
        [bomb2 runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction waitForDuration:0.1], [SKAction setTexture:[SKTexture textureWithImageNamed:@"bigbomb2"]], [SKAction waitForDuration:0.1],[SKAction setTexture:bombTexture]]]]];
        
        if (r2 == 0)
        {
            bomb.position = CGPointMake(xpos2, yposBomb);
            bomb2.position = CGPointMake(xpos3, yposBomb);
        }
        else if (r2 == 1)
        {
            bomb.position = CGPointMake(xpos1, yposBomb);
            bomb.position = CGPointMake(xpos3, yposBomb);
        }
        else
        {
            bomb.position = CGPointMake(xpos1, yposBomb);
            bomb.position = CGPointMake(xpos2, yposBomb);
        }
        [self addChild:bomb];
        [self addChild:bomb2];
    }
    else
    {
        int r2 = arc4random()%3;
        SKSpriteNode *bomb = [[SKSpriteNode alloc] initWithTexture:bombTexture];
        bomb.name = @"bomb";
        bomb.size = CGSizeMake(110, 192);
        bomb.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(bomb.size.width, bomb.size.height/2) center:CGPointMake(0, -bomb.size.height/4)];
        bomb.physicsBody.categoryBitMask = bombCategory;
        bomb.physicsBody.dynamic = YES;
        bomb.physicsBody.contactTestBitMask = manCategory;
        bomb.physicsBody.collisionBitMask = 0x0;
        [bomb runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction waitForDuration:0.1], [SKAction setTexture:[SKTexture textureWithImageNamed:@"bigbomb2"]], [SKAction waitForDuration:0.1],[SKAction setTexture:bombTexture]]]]];
        
        SKSpriteNode *bomb2 = [[SKSpriteNode alloc] initWithTexture:bombTexture];
        bomb2.name = @"bomb";
        bomb2.size = CGSizeMake(110, 192);
        bomb2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(bomb.size.width, bomb.size.height/2) center:CGPointMake(0, -bomb.size.height/4)];
        bomb2.physicsBody.categoryBitMask = bombCategory;
        bomb2.physicsBody.dynamic = YES;
        bomb2.physicsBody.contactTestBitMask = manCategory;
        bomb2.physicsBody.collisionBitMask = 0x0;
        [bomb2 runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction waitForDuration:0.1], [SKAction setTexture:[SKTexture textureWithImageNamed:@"bigbomb2"]], [SKAction waitForDuration:0.1],[SKAction setTexture:bombTexture]]]]];
        
        SKSpriteNode *coin = [[SKSpriteNode alloc] initWithTexture:coinTexture];
        coin.size = CGSizeMake(110, 110);
        coin.name = @"coin";
        coin.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:coin.size];
        coin.physicsBody.categoryBitMask = coinCategory;
        coin.physicsBody.collisionBitMask = 0x0;
        coin.physicsBody.contactTestBitMask = manCategory;
        
        if (r2 == 0)
        {
            coin.position = CGPointMake(xpos1, yposCoin);
            bomb.position = CGPointMake(xpos2, yposBomb);
            bomb2.position = CGPointMake(xpos3, yposBomb);
        }
        else if (r2 == 1)
        {
            coin.position = CGPointMake(xpos2, yposCoin);
            bomb.position = CGPointMake(xpos1, yposBomb);
            bomb2.position = CGPointMake(xpos3, yposBomb);
        }
        else
        {
            coin.position = CGPointMake(xpos3, yposCoin);
            bomb.position = CGPointMake(xpos1, yposBomb);
            bomb2.position = CGPointMake(xpos2, yposBomb);
        }
        
        [self addChild:bomb];
        [self addChild:bomb2];
        [self addChild:coin];
    }
    
}
// C inline function for generating numbers in parameter range
static inline float randomNumber(int high, int low)
{
    float f = (float)rand()/RAND_MAX;
    
    return low + f*(high-low);
}

#pragma mark - Touch Control
// Method called by view that reacts when touches begin on the screen. If the game isnt started and the menu isnt showing the game is then started. If the game is not started and menu is showing the buttons are pressed or released. If the game is started and menu not showing the user moves to the desired side. If there is a two finger touch on the screen the user stays in the middle. This controls all animations
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.menuShowing)
    {
        UITouch *touch = (UITouch*)[touches anyObject];
        CGPoint location = [touch locationInNode:self];
        SKNode *node = [self nodeAtPoint:location];
        if ([node.name isEqualToString:@"replayButton"])
        {
            [node runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"replay buttonpressed.png"]]];
        }
        else if ([node.name isEqualToString:@"mainMenuButton"])
        {
            [node runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"main menu buttonpressed.png"]]];
        }
    }
    else if (!self.gameStarted)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideAd" object:nil];
        coinsCollected = 0;
        self.gameStarted = YES;
        SKNode *node = [self childNodeWithName:@"tapButton"];
        [node removeFromParent];
        
        SKAction *genEvents = [SKAction sequence:@[[SKAction waitForDuration:eventGenDelay], [SKAction performSelector:@selector(generateSetOfEvents) onTarget:self]]];
        [self runAction:genEvents withKey:@"genSets"];
        numberOfEvents = 0;
        
    }
    else
    {
        NSArray *touchArray = [touches allObjects];
        
        if (touchArray.count>=2||[event allTouches].count>=2)
        {
            [man moveCenter];
            man.position = CGPointMake(CGRectGetMidX(self.frame), man.position.y);
            [leftArrow press];
            [rightArrow press];
        }
        else if (touchArray.count == 1)
        {
            for (int k = 0;k<touchArray.count;k++)
            {
                UITouch *touch = (UITouch*)[touchArray objectAtIndex:k];
                CGPoint location = [touch locationInNode:self];
                
                if (location.x<CGRectGetMidX(self.frame))
                {
                    [man moveLeft];
                    man.position = CGPointMake(man.size.width/2, man.position.y);
                    [leftArrow press];
                }
                else
                {
                    [man moveRight];
                    man.position = CGPointMake(CGRectGetMaxX(self.frame)-man.size.width/2, man.position.y);
                    [rightArrow press];
                }
            }
        }
        else
            return;
    }
}

//Resets man and arrows to center if it goes from one touch to no touch. If 2-1 touch it will go to the remaining touch.
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.menuShowing)
    {
        UITouch *touch = (UITouch*)[touches anyObject];
        CGPoint location = [touch locationInNode:self];
        SKNode *node = [self nodeAtPoint:location];
        if ([node.name isEqualToString:@"replayButton"])
        {
            [self restartAndSaveGame];
        }
        else if ([node.name isEqualToString:@"mainMenuButton"])
        {
            MainMenuScene *mainMenuScene = [[MainMenuScene alloc] initWithSize:self.view.bounds.size];
            mainMenuScene.bigButtonAtlas = [SKTextureAtlas atlasNamed:@"wideButton"];
            mainMenuScene.smallButtonAtlas = [SKTextureAtlas atlasNamed:@"smallButton"];
            [self.view presentScene:mainMenuScene transition:[SKTransition fadeWithDuration:2]];
        }
    }
    else if (!self.gameStarted)
        return;
    else
    {
        NSArray *touchArray = [touches allObjects];
        
        if (touchArray.count>=2)
        {
            [man moveCenter];
            man.position = CGPointMake(CGRectGetMidX(self.frame), man.position.y);
            [leftArrow reset];
            [rightArrow reset];
        }
        else if (touchArray.count == 1)
        {
            if ([event allTouches].count==2)
            {
                for (int k = 0;k<touchArray.count;k++)
                {
                    UITouch *touch = (UITouch*)[touchArray objectAtIndex:k];
                    CGPoint location = [touch locationInNode:self];
                    if (location.x<CGRectGetMidX(self.frame))
                    {
                        [man moveRight];
                        man.position = CGPointMake(CGRectGetMaxX(self.frame)-man.size.width/2, man.position.y);
                        [leftArrow reset];
                    }
                    else
                    {
                        [man moveLeft];
                        man.position = CGPointMake(man.size.width/2, man.position.y);
                        [rightArrow reset];
                    }
                }
            }
            else if ([event allTouches].count == 1)
            {
                [man moveCenter];
                man.position = CGPointMake(CGRectGetMidX(self.frame), man.position.y);
                [leftArrow reset];
                [rightArrow reset];
            }
        }
        else
            return;
    }
}

@end
