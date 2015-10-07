//
//  GameScene.m
//  Tylers app Revised
//
//  Created by Eric Dufresne on 2014-10-07.
//  Copyright (c) 2014 Eric Dufresne. All rights reserved.
//
//  -- Start of Code --

//  Preprocessor import and define statements
#import "NewGameScene.h"
#import "MainMenuScene.h"
#import "Man.h"
#import "Arrow.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"


#define powerupChance 0.05
#define FRBaseTime 4
#define FRBufferTime 1.5
#define baseSensitivity 0.15
#define sensitivityFactor 0.05

//  Private Scene Variables
@interface NewGameScene ()
{
    Arrow *leftArrow;
    Arrow *rightArrow;
    Man *man;
    SKSpriteNode *background;
    SKSpriteNode *tapButton;
    SKAction *coinSound;
    SKAction *cheatDeathSound;
    SKAction *extraCoinSound;
    SKAction *powerupSound;
    
    NSInteger numberOfEvents;
    NSInteger extraTime;
    SKTexture *coinTexture;
    SKTexture *bombTexture;
    CGFloat yposCoin;
    CGFloat yposBomb;
    CGFloat xpos1;
    CGFloat xpos2;
    CGFloat xpos3;
    SKLabelNode *counter;
    
    NSTimer *timer;
    NSTimer *incrementTimer;
}
@property BOOL contentCreated;
@property BOOL gameStarted;
@property BOOL menuShowing;
@property BOOL jackpot;
@property BOOL fastReflexes;
@property (strong, nonatomic) NSNumber *highScore;

@property BOOL tiltControls;
@property int sensitivity;
@property (strong, nonatomic) CMMotionManager *manager;
@end

//  Start Of Implementation
@implementation NewGameScene
@synthesize coinsCollected, arrowAtlas, manAtlas;

// Category 32 bit masks for physics contact and collision. Shifted so all bits are out of place //
static const uint32_t manCategory = 0x1 << 0;
static const uint32_t coinCategory = 0x1 << 1;
static const uint32_t bombCategory = 0x1 << 2;
static const uint32_t fastReflexesCateory = 0x1 << 3;
static const uint32_t jackpotCategory = 0x1 << 4;
static const uint32_t invincibilityCategory = 0x1 << 5;
static const uint32_t invincibleManCategory = 0x1 << 6;

// Event parameters that are variable to numberOfEvents //
static double eventGenDelay = 1.5;
static int eventMin = 10;
static int eventMax = 25;
static double timeInBetweenEvents = 0;

#pragma mark - Initialization

//Initialization method that creates initial gravity force, initializes reused textures for generated objects and positions for generated objects. If tilt controls selected creates a gyro manager that takes samples of pitch, yaw, and roll every 1/60th second//
-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        self.physicsWorld.contactDelegate = self;
        coinTexture = [SKTexture textureWithImageNamed:@"coin.png"];
        bombTexture = [SKTexture textureWithImageNamed:@"bigbomb1.png"];
        
        yposCoin = CGRectGetMaxY(self.frame)+27;
        yposBomb = CGRectGetMaxY(self.frame)+43;
        xpos1 = CGRectGetMinX(self.frame)+48;
        xpos2 = CGRectGetMidX(self.frame);
        xpos3 = CGRectGetMaxX(self.frame)-48;
        
        self.tiltControls = [[NSUserDefaults standardUserDefaults] boolForKey:@"tiltControls"];
        self.sensitivity = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"sensitivity"];
        if (self.sensitivity<0||self.sensitivity>5)
            self.sensitivity = 3;
        self.sensitivity-=3;
        if (self.tiltControls){
            self.manager = [[CMMotionManager alloc] init];
            self.manager.gyroUpdateInterval = 1/60;
            self.manager.deviceMotionUpdateInterval = 1/60;
            [self.manager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
                if (error){
                    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"GYRO FAILED" userInfo:nil];
                }
                CMAttitude *attitude = self.manager.deviceMotion.attitude;
                if (self.gameStarted){
                    NSLog(@"%f", attitude.roll);
                    if (attitude.roll<-baseSensitivity+self.sensitivity*sensitivityFactor){
                        NSLog(@"Left");
                        [man moveLeft];
                        [leftArrow press];
                        [rightArrow reset];
                        man.position = CGPointMake(man.size.width/2, man.position.y);
                    }
                    else if (attitude.roll>baseSensitivity+self.sensitivity*sensitivityFactor){
                        NSLog(@"Right");
                        [man moveRight];
                        [leftArrow reset];
                        [rightArrow press];
                        man.position = CGPointMake(CGRectGetMaxX(self.frame)-man.size.width/2, man.position.y);
                    }
                    else{
                        NSLog(@"Center");
                        [man moveCenter];
                        [leftArrow reset];
                        [rightArrow reset];
                        man.position = CGPointMake(CGRectGetMidX(self.frame), man.position.y);
                    }
                }
            }];
        }
    }
    return self;
}
// Called when SKView is presented by root View controller. Initializes sound, loads previous high score and creates initial scene content //
-(void)didMoveToView:(SKView *)view
{
    coinSound = [SKAction playSoundFileNamed:@"coinsound.mp3" waitForCompletion:NO];
    cheatDeathSound = [SKAction playSoundFileNamed:@"cheatDeath.mp3" waitForCompletion:NO];
    extraCoinSound = [SKAction playSoundFileNamed:@"extraCoin.mp3" waitForCompletion:NO];
    powerupSound = [SKAction playSoundFileNamed:@"powerup.wav" waitForCompletion:NO];
    
    if (!self.contentCreated)
    {
        self.highScore = [[NSUserDefaults standardUserDefaults]objectForKey:@"highScore"];
        
        if (self.highScore==nil)
            self.highScore = [[NSNumber alloc]initWithInteger:0];
        
        [self createSceneContent];
        self.contentCreated=YES;
        AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [delegate retrievePurchaseData];
        self.passiveKeyVals = delegate.passiveKeyVals;
        self.powerupIdentifiers = delegate.powerupIdentifiers;
        NSNumber *number = [self.passiveKeyVals objectForKey:@"powerMaster"];
        extraTime = number.unsignedIntegerValue*2;
        self.backgroundColor = [SKColor whiteColor];
        ViewController *viewController = (ViewController*)self.view.window.rootViewController;
        viewController.screenName = @"Game Screen";
    }
}

#pragma mark - Scene Creation
// Implementation to create scene content at the start of when the scene is presented or when the game is reset. Creates and places all starting nodes in the view and shows tap to press to start the game
-(void)createSceneContent
{
    self.jackpot = NO;
    self.fastReflexes = NO;
    self.physicsWorld.gravity = CGVectorMake(0, -4.3);
    self.physicsWorld.speed = 1;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showAd" object:nil];
    
    NSString *selectedSkin = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedSkin"];
    if ([selectedSkin isEqualToString:@"ninjaSkin"])
        background = [[SKSpriteNode alloc] initWithImageNamed:@"ninja_background.png"];
    else
        background = [[SKSpriteNode alloc] initWithImageNamed:@"background.png"];
    
    background.size = CGSizeMake(CGRectGetMaxX(self.frame), CGRectGetMaxY(self.frame));
    background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    background.zPosition = 0;
    [self addChild:background];
    SKSpriteNode *bluebar = [[SKSpriteNode alloc]initWithImageNamed:@"bluebar.png"];
    bluebar.size = CGSizeMake(CGRectGetMaxX(self.frame), 90);
    CGPoint pos = CGPointMake(CGRectGetMidX(self.frame), bluebar.size.height/2);
    bluebar.position=pos;
    bluebar.zPosition=2;
    bluebar.name = @"bluebar";
    
    counter = [[SKLabelNode alloc] initWithFontNamed:@"04b_19"];
    counter.fontColor = [SKColor whiteColor];
    counter.fontSize = 60;
    counter.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(bluebar.frame)-25);
    counter.alpha = 0;
    counter.text = @"0";
    counter.zPosition = 3;
    [self addChild:counter];
    
    [self addChild:bluebar];
    leftArrow = [[Arrow alloc]initLeftArrowWithPosition:CGPointMake(50, CGRectGetMidY(bluebar.frame)+2) withTextureAtlas:arrowAtlas];
    leftArrow.name = @"leftArrow";
    leftArrow.zPosition=3;
    [self addChild:leftArrow];
    rightArrow = [[Arrow alloc]initRightArrowWithPosition:CGPointMake( CGRectGetMaxX(bluebar.frame)-50,leftArrow.position.y)withTextureAtlas:arrowAtlas];
    rightArrow.name = @"rightArrow";
    rightArrow.zPosition=3;
    [self addChild:rightArrow];
    man = [[Man alloc] initWithManAtlas:manAtlas];
    man.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMaxY(bluebar.frame)+man.size.width/2-3);
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
    static int sessionCount = 0;
    sessionCount++;
    [background runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"dead screen.png"]]];
    [self addChild:background];
    
    
    SKSpriteNode *bluebar = [[SKSpriteNode alloc]initWithImageNamed:@"bluebar.png"];
    bluebar.size = CGSizeMake(CGRectGetMaxX(self.frame), 90);
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
    deadmenu.size = CGSizeMake(300, 205);
    deadmenu.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMaxY(self.frame)-deadmenu.size.height/2-45);
    [self addChild:deadmenu];
    SKSpriteNode *mainMenuButton = [[SKSpriteNode alloc]initWithImageNamed:@"main menu button.png"];
    mainMenuButton.size = CGSizeMake(103, 73);
    mainMenuButton.position = CGPointMake(-67, -35);
    mainMenuButton.name = @"mainMenuButton";
    [deadmenu addChild:mainMenuButton];
    SKSpriteNode *replayButton = [[SKSpriteNode alloc]initWithImageNamed:@"replay button.png"];
    replayButton.size = CGSizeMake(107,73);
    replayButton.position = CGPointMake(67,-35);
    replayButton.name = @"replayButton";
    [deadmenu addChild:replayButton];
    
    SKLabelNode *highScoreLabel = [[SKLabelNode alloc] initWithFontNamed:@"04b03"];
    highScoreLabel.fontColor = [SKColor blackColor];
    highScoreLabel.fontSize = 30;
    highScoreLabel.text = [NSString stringWithFormat:@"%i", self.highScore.intValue];
    highScoreLabel.position = CGPointMake(0, 45);
    [replayButton addChild:highScoreLabel];
    
    SKLabelNode *currentScoreLabel = [[SKLabelNode alloc] initWithFontNamed:@"04b03"];
    currentScoreLabel.fontColor = [SKColor blackColor];
    currentScoreLabel.fontSize = 30;
    currentScoreLabel.text = [NSString stringWithFormat:@"%i", (int)self.coinsCollected];
    currentScoreLabel.position = CGPointMake(0, 45);
    [mainMenuButton addChild:currentScoreLabel];
    
    SKLabelNode *stashLabel = [[SKLabelNode alloc] initWithFontNamed:@"04b03"];
    stashLabel.fontColor = [SKColor blackColor];
    stashLabel.fontSize = 20;
    stashLabel.text = [NSString stringWithFormat:@"Stash: %i Coins", (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"coinPurse"]];
    stashLabel.position = CGPointMake(0, -deadmenu.size.height/2+5);
    [deadmenu addChild:stashLabel];

    //Shows ad after game is done. Every third game shows ad
    [self runAction:[SKAction sequence:@[[SKAction waitForDuration:2.5], [SKAction runBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showAd" object:nil];
    }]]]];
    if (sessionCount%3==0&&sessionCount>0)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showInterstitial" object:nil];
    }
    // Tracks player score to google analytics
    id <GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Game Action" action:[NSString stringWithFormat:@"Finisehd Game With Score: %i", (int)coinsCollected] label:[NSString stringWithFormat:@"Scored: %i", (int)coinsCollected] value:nil]build]];
}

#pragma mark SK Methods

//SKPhysicsContact delegate method that is called whenever the logic OR of two contacting category bitmasks intersect. Ends game if player comes in contact with bomb or removes coin, adds it to the score and then in a background thread increments the counter //
-(void)didBeginContact:(SKPhysicsContact *)contact
{
    if (contact.bodyA.categoryBitMask == bombCategory || contact.bodyB.categoryBitMask == bombCategory)
    {
        NSNumber *number = [self.passiveKeyVals objectForKey:@"cheatDeath"];
        if (number.unsignedIntegerValue == 0)
            [self endGame];
        else{
            float random = randomNumber(1, 0);
            if (!(random<=0.15||(random<=0.25&&number.unsignedIntegerValue==2)||(random<=0.35&&number.unsignedIntegerValue==3)||(random<=0.45&&number.unsignedIntegerValue==4)))
                [self endGame];
            else{
                if ([contact.bodyA.node isEqual:man])
                    [contact.bodyB.node removeFromParent];
                else
                    [contact.bodyA.node removeFromParent];
                
                [self runAction:cheatDeathSound];
                if (contact.bodyA.categoryBitMask == bombCategory){
                    SKNode *node = contact.bodyA.node;
                    [node runAction:[SKAction sequence:@[[SKAction fadeAlphaTo:0 duration:1], [SKAction removeFromParent]]]];
                }
                else{
                    SKNode *node = contact.bodyB.node;
                    [node runAction:[SKAction sequence:@[[SKAction fadeAlphaTo:0 duration:1], [SKAction removeFromParent]]]];
                }
                [man expandBag];
            }
        }
        
    }
    else if (contact.bodyA.categoryBitMask == coinCategory || contact.bodyB.categoryBitMask == coinCategory)
    {
        if (contact.bodyA.categoryBitMask == coinCategory)
            [contact.bodyA.node removeFromParent];
        else
            [contact.bodyB.node removeFromParent];
        
        NSNumber *number = [self.passiveKeyVals objectForKey:@"moneyMaker"];
        if (number.unsignedIntegerValue == 0)
        {
            coinsCollected++;
            counter.text = [NSString stringWithFormat:@"%i", (int)coinsCollected];
            counter.alpha = 1;
            [self runAction:coinSound];
            [man expandBag];
        }
        else{
            float random = randomNumber(1, 0);
            if (number.unsignedIntegerValue==1&&random<=0.05)
            {
                coinsCollected+=2;
                [self runAction:extraCoinSound];
            }
            else if (number.unsignedIntegerValue==2&&random<=0.10){
                coinsCollected+=3;
                [self runAction:extraCoinSound];
            }
            else if (number.unsignedIntegerValue==3&&random<=0.15){
                coinsCollected+=4;
                [self runAction:extraCoinSound];
            }
            else if (number.unsignedIntegerValue==4&&random<=0.20){
                coinsCollected+=5;
                [self runAction:extraCoinSound];
            }
            else{
                coinsCollected++;
                [self runAction:coinSound];
            }
            
            [man expandBag];
            counter.text = [NSString stringWithFormat:@"%i", (int)coinsCollected];
            counter.alpha = 1;
        }
    }
    else if (contact.bodyA.categoryBitMask == invincibilityCategory || contact.bodyB.categoryBitMask == invincibilityCategory){
        if ([contact.bodyA.node isEqual:man])
            [contact.bodyB.node removeFromParent];
        else
            [contact.bodyA.node removeFromParent];
        NSUInteger invincibleTime = 5+extraTime;
        SKAction *warning = [SKAction sequence:@[[SKAction fadeAlphaTo:1 duration:0], [SKAction waitForDuration:0.2], [SKAction fadeAlphaTo:0.5 duration:0], [SKAction waitForDuration:0.2]]];
                             
        SKAction *action = [SKAction sequence:@[[SKAction fadeAlphaTo:0.5 duration:0], [SKAction waitForDuration:invincibleTime-2], [SKAction repeatAction:warning count:5], [SKAction fadeAlphaTo:1 duration:0], [SKAction runBlock:^{
            man.physicsBody.categoryBitMask = manCategory;
        }]]];
        [man expandBag];
        [man runAction:action];
        [self runAction:powerupSound];
        man.physicsBody.categoryBitMask = invincibleManCategory;
    }
    else if (contact.bodyA.categoryBitMask == fastReflexesCateory || contact.bodyB.categoryBitMask == fastReflexesCateory){
        
        if ([contact.bodyA.node isEqual:man])
            [contact.bodyB.node removeFromParent];
        else
            [contact.bodyA.node removeFromParent];
        
        if (self.fastReflexes)
            return;
        else
            self.fastReflexes = YES;
        
        self.speed = 0.5;
        self.physicsWorld.speed = 0.5;
        timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(tick) userInfo:nil repeats:NO];
        
        SKSpriteNode *shade = [[SKSpriteNode alloc] initWithColor:[SKColor darkGrayColor] size:self.size];
        shade.name = @"shade";
        shade.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        shade.alpha = 0.5;
        [man expandBag];
        [self runAction:powerupSound];
        [self addChild:shade];
    }
    else if (contact.bodyA.categoryBitMask == jackpotCategory || contact.bodyB.categoryBitMask == jackpotCategory){
        if ([contact.bodyA.node isEqual:man])
            [contact.bodyB.node removeFromParent];
        else
            [contact.bodyA.node removeFromParent];
        
        self.jackpot = YES;
        [self runAction:[SKAction sequence:@[[SKAction waitForDuration:extraTime+FRBaseTime-FRBufferTime], [SKAction runBlock:^{
            self.jackpot = NO;
        }]]]];
        [self runAction:powerupSound];
        [man expandBag];
    }
}
//Timer methods used when the slow motion powerup is used. The overall processing speed of the scene is slowed down so SKActions cannot be used so an NSTimer will keep track of how much time the speed will be slowed and then will gradually return to normal speed every 0.1 seconds.
#define FRtime (FRBaseTime+extraTime-FRBufferTime)
-(void)tick{
    incrementTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(incrementTick) userInfo:nil repeats:YES];
}
//Incremently increases speed
-(void)incrementTick{
    self.speed+=0.5/(FRBufferTime/0.1);
    self.physicsWorld.speed += 0.5/(FRBufferTime/0.1);
    SKNode *node = [self childNodeWithName:@"shade"];
    node.alpha -= 0.5/(FRBufferTime/0.1);
    
    if (self.speed>=1&&self.physicsWorld.speed>=1)
    {
        [[self childNodeWithName:@"shade"] removeFromParent];
        self.speed = 1;
        self.physicsWorld.speed = 1;
        [incrementTimer invalidate];
        incrementTimer = nil;
        self.fastReflexes = NO;
    }
}

#pragma mark - Game Control

//  Method called at the start of the scene to prompt user to tap screen to start
-(void)showTapButton
{
    tapButton = [[SKSpriteNode alloc]initWithImageNamed:@"tap to start.png"];
    tapButton.size = CGSizeMake(300, 160);
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
    self.speed = 1;
    self.physicsWorld.speed = 1;
    
    SKSpriteNode *flash = [[SKSpriteNode alloc] initWithColor:[UIColor whiteColor] size:self.frame.size];
    flash.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    flash.zPosition = 4;

    SKAction *action = [SKAction group:@[[SKAction playSoundFileNamed:@"explosion.mp3" waitForCompletion:NO],[SKAction sequence:@[[SKAction waitForDuration:1], [SKAction fadeAlphaTo:0 duration:0.7], [SKAction removeFromParent]]]]];
    
    [flash runAction:action];
    [self addChild:flash];
    
    if (coinsCollected>self.highScore.integerValue)
    {
        self.highScore = [NSNumber numberWithInteger:coinsCollected];
        [[NSUserDefaults standardUserDefaults]setObject:self.highScore forKey:@"highScore"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    NSInteger purse = [[NSUserDefaults standardUserDefaults] integerForKey:@"coinPurse"];
    purse+=coinsCollected;
    [[NSUserDefaults standardUserDefaults] setInteger:purse forKey:@"coinPurse"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
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
    //timeInBetweenEvents = pow(3, -(numberOfEvents-0.25))+0.35;
    timeInBetweenEvents = pow(2,-(numberOfEvents - 0.35))+0.25;
    if (self.physicsWorld.gravity.dy>-25)
        self.physicsWorld.gravity = CGVectorMake(0, self.physicsWorld.gravity.dy-1.75);
    else if (self.physicsWorld.gravity.dy>-35)
    {
        NSLog(@"Past peak");
        self.physicsWorld.gravity = CGVectorMake(0, self.physicsWorld.gravity.dy-0.125);
    }
    
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
    if (self.jackpot)
    {
        [self generateJackpot];
        return;
    }
    float r = randomNumber(1, 0);
    float powerup = randomNumber(1, 0);
    if (powerup<=powerupChance&&self.powerupIdentifiers.count!=0&&!self.jackpot&&!self.fastReflexes&&!(man.physicsBody.categoryBitMask == invincibleManCategory))
    {
        [self generateEventWithPowerup];
        return;
    }
    if (r<0.2||numberOfEvents==0)
    {
        int r2 = arc4random()%3;
        SKSpriteNode *bomb = [[SKSpriteNode alloc] initWithTexture:bombTexture];
        bomb.size = CGSizeMake(55, 86);
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
        coin.size = CGSizeMake(55, 55);
        coin.name = @"coin";
        coin.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:coin.size];
        coin.physicsBody.categoryBitMask = coinCategory;
        coin.physicsBody.collisionBitMask = 0x0;
        coin.physicsBody.contactTestBitMask = manCategory | invincibleManCategory;
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
        coin.size = CGSizeMake(55, 55);
        coin.name = @"coin";
        coin.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:coin.size];
        coin.physicsBody.categoryBitMask = coinCategory;
        coin.physicsBody.collisionBitMask = 0x0;
        coin.physicsBody.contactTestBitMask = manCategory | invincibleManCategory;
        
        SKSpriteNode *bomb = [[SKSpriteNode alloc] initWithTexture:bombTexture];
        bomb.size = CGSizeMake(55, 86);
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
        bomb.size = CGSizeMake(55, 86);
        bomb.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(bomb.size.width, bomb.size.height/2) center:CGPointMake(0, -bomb.size.height/4)];
        bomb.physicsBody.categoryBitMask = bombCategory;
        bomb.physicsBody.dynamic = YES;
        bomb.physicsBody.contactTestBitMask = manCategory;
        bomb.physicsBody.collisionBitMask = 0x0;
        [bomb runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction waitForDuration:0.1], [SKAction setTexture:[SKTexture textureWithImageNamed:@"bigbomb2"]], [SKAction waitForDuration:0.1],[SKAction setTexture:bombTexture]]]]];
        
        SKSpriteNode *bomb2 = [[SKSpriteNode alloc] initWithTexture:bombTexture];
        bomb2.name = @"bomb";
        bomb2.size = CGSizeMake(55, 86);
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
        bomb.size = CGSizeMake(55, 86);
        bomb.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(bomb.size.width, bomb.size.height/2) center:CGPointMake(0, -bomb.size.height/4)];
        bomb.physicsBody.categoryBitMask = bombCategory;
        bomb.physicsBody.dynamic = YES;
        bomb.physicsBody.contactTestBitMask = manCategory;
        bomb.physicsBody.collisionBitMask = 0x0;
        [bomb runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction waitForDuration:0.1], [SKAction setTexture:[SKTexture textureWithImageNamed:@"bigbomb2"]], [SKAction waitForDuration:0.1],[SKAction setTexture:bombTexture]]]]];
        
        SKSpriteNode *bomb2 = [[SKSpriteNode alloc] initWithTexture:bombTexture];
        bomb2.name = @"bomb";
        bomb2.size = CGSizeMake(55, 86);
        bomb2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(bomb.size.width, bomb.size.height/2) center:CGPointMake(0, -bomb.size.height/4)];
        bomb2.physicsBody.categoryBitMask = bombCategory;
        bomb2.physicsBody.dynamic = YES;
        bomb2.physicsBody.contactTestBitMask = manCategory;
        bomb2.physicsBody.collisionBitMask = 0x0;
        [bomb2 runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction waitForDuration:0.1], [SKAction setTexture:[SKTexture textureWithImageNamed:@"bigbomb2"]], [SKAction waitForDuration:0.1],[SKAction setTexture:bombTexture]]]]];
        
        SKSpriteNode *coin = [[SKSpriteNode alloc] initWithTexture:coinTexture];
        coin.size = CGSizeMake(55, 55);
        coin.name = @"coin";
        coin.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:coin.size];
        coin.physicsBody.categoryBitMask = coinCategory;
        coin.physicsBody.collisionBitMask = 0x0;
        coin.physicsBody.contactTestBitMask = manCategory | invincibleManCategory;
        
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
// SECOND algorithm that is called from the MAIN algorithm if it is determined a powerup will be generated in place of a coin. algorithm determines bombs that fall beside powerup if any as well as the position of the powerup
-(void)generateEventWithPowerup{
    int type = arc4random()%self.powerupIdentifiers.count;
    
    NSString *identifier = [self.powerupIdentifiers objectAtIndex:type];
    SKSpriteNode *powerup;
    if ([identifier isEqualToString:@"fastReflexes"]){
        powerup = [[SKSpriteNode alloc] initWithTexture:[self.itemAtlas textureNamed:@"hourglass"]];
        powerup.size = CGSizeMake(55, 86);
        powerup.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:powerup.size];
        powerup.physicsBody.categoryBitMask = fastReflexesCateory;
    }
    else if ([identifier isEqualToString:@"jackpot"]){
        powerup = [[SKSpriteNode alloc] initWithTexture:[self.itemAtlas textureNamed:@"jackpot"]];
        powerup.size = CGSizeMake(55, 86);
        powerup.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:powerup.size];
        powerup.physicsBody.categoryBitMask = jackpotCategory;
    }
    else{
        powerup = [[SKSpriteNode alloc] initWithTexture:[self.itemAtlas textureNamed:@"shield"]];
        powerup.size = CGSizeMake(55, 86);
        powerup.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:powerup.size];
        powerup.physicsBody.categoryBitMask = invincibilityCategory;
    }
    powerup.physicsBody.contactTestBitMask = manCategory;
    powerup.physicsBody.collisionBitMask = 0x0;
    powerup.name = @"powerup";
    float r1 = randomNumber(1, 0);
    if (r1<0.33){
        int r2 = arc4random()%3;
        if (r2 == 0)
            powerup.position = CGPointMake(xpos1, yposBomb);
        else if (r2 == 1)
            powerup.position = CGPointMake(xpos2, yposBomb);
        else
            powerup.position = CGPointMake(xpos3, yposBomb);
        [self addChild:powerup];
    }
    else if (r1<0.66){
        SKSpriteNode *bomb = [[SKSpriteNode alloc] initWithTexture:bombTexture];
        bomb.name = @"bomb";
        bomb.size = CGSizeMake(55, 86);
        bomb.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(bomb.size.width, bomb.size.height/2) center:CGPointMake(0, -bomb.size.height/4)];
        bomb.physicsBody.categoryBitMask = bombCategory;
        bomb.physicsBody.dynamic = YES;
        bomb.physicsBody.contactTestBitMask = manCategory;
        bomb.physicsBody.collisionBitMask = 0x0;
        [bomb runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction waitForDuration:0.1], [SKAction setTexture:[SKTexture textureWithImageNamed:@"bigbomb2"]], [SKAction waitForDuration:0.1],[SKAction setTexture:bombTexture]]]]];
        int r2 = arc4random()%6;
        if (r2 == 0){
            powerup.position = CGPointMake(xpos1, yposBomb);
            bomb.position = CGPointMake(xpos2, yposBomb);
        }
        else if (r2 == 1){
            powerup.position = CGPointMake(xpos2, yposBomb);
            bomb.position = CGPointMake(xpos1, yposBomb);
        }
        else if (r2 == 2){
            powerup.position = CGPointMake(xpos1, yposBomb);
            bomb.position = CGPointMake(xpos3, yposBomb);
        }
        else if (r2 == 3){
            powerup.position = CGPointMake(xpos3, yposBomb);
            bomb.position = CGPointMake(xpos1, yposBomb);
        }
        else if (r2 == 4){
            powerup.position = CGPointMake(xpos2, yposBomb);
            bomb.position = CGPointMake(xpos3, yposBomb);
        }
        else{
            powerup.position = CGPointMake(xpos3, yposBomb);
            bomb.position = CGPointMake(xpos2, yposBomb);
        }
        [self addChild:powerup];
        [self addChild:bomb];
    }
    else{
        int r2 = arc4random()%3;
        SKSpriteNode *bomb = [[SKSpriteNode alloc] initWithTexture:bombTexture];
        bomb.name = @"bomb";
        bomb.size = CGSizeMake(55, 86);
        bomb.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(bomb.size.width, bomb.size.height/2) center:CGPointMake(0, -bomb.size.height/4)];
        bomb.physicsBody.categoryBitMask = bombCategory;
        bomb.physicsBody.dynamic = YES;
        bomb.physicsBody.contactTestBitMask = manCategory;
        bomb.physicsBody.collisionBitMask = 0x0;
        [bomb runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction waitForDuration:0.1], [SKAction setTexture:[SKTexture textureWithImageNamed:@"bigbomb2"]], [SKAction waitForDuration:0.1],[SKAction setTexture:bombTexture]]]]];

        SKSpriteNode *bomb2 = [[SKSpriteNode alloc] initWithTexture:bombTexture];
        bomb2.name = @"bomb";
        bomb2.size = CGSizeMake(55, 86);
        bomb2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(bomb.size.width, bomb.size.height/2) center:CGPointMake(0, -bomb.size.height/4)];
        bomb2.physicsBody.categoryBitMask = bombCategory;
        bomb2.physicsBody.dynamic = YES;
        bomb2.physicsBody.contactTestBitMask = manCategory;
        bomb2.physicsBody.collisionBitMask = 0x0;
        [bomb2 runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction waitForDuration:0.1], [SKAction setTexture:[SKTexture textureWithImageNamed:@"bigbomb2"]], [SKAction waitForDuration:0.1],[SKAction setTexture:bombTexture]]]]];
        if (r2 == 0){
            powerup.position = CGPointMake(xpos1, yposBomb);
            bomb.position = CGPointMake(xpos2, yposBomb);
            bomb2.position = CGPointMake(xpos3, yposBomb);
        }
        else if (r2 == 1){
            powerup.position = CGPointMake(xpos2, yposBomb);
            bomb.position = CGPointMake(xpos1, yposBomb);
            bomb2.position = CGPointMake(xpos3, yposBomb);
        }
        else{
            powerup.position = CGPointMake(xpos3, yposBomb);
            bomb.position = CGPointMake(xpos2, yposBomb);
            bomb2.position = CGPointMake(xpos1, yposBomb);
        }
        [self addChild:powerup];
        [self addChild:bomb];
        [self addChild:bomb2];
    }
}
//If a jackpot is retrieved by the player. Randomly generates between 1-3 coins for event in random positions.
-(void)generateJackpot{
    float r1 = randomNumber(1, 0);
    if (r1 <=0.33){
        int r2 = arc4random()%3;
        SKSpriteNode *coin = [[SKSpriteNode alloc] initWithTexture:coinTexture];
        coin.size = CGSizeMake(55, 55);
        coin.name = @"coin";
        coin.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:coin.size];
        coin.physicsBody.categoryBitMask = coinCategory;
        coin.physicsBody.collisionBitMask = 0x0;
        coin.physicsBody.contactTestBitMask = manCategory | invincibleManCategory;
        if (r2 == 0)
            coin.position = CGPointMake(xpos1, yposCoin);
        else if (r2 == 1)
            coin.position = CGPointMake(xpos2, yposCoin);
        else
            coin.position = CGPointMake(xpos3, yposCoin);
        [self addChild:coin];
    }
    else if (r1<=0.66){
        SKSpriteNode *coin = [[SKSpriteNode alloc] initWithTexture:coinTexture];
        coin.size = CGSizeMake(55, 55);
        coin.name = @"coin";
        coin.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:coin.size];
        coin.physicsBody.categoryBitMask = coinCategory;
        coin.physicsBody.collisionBitMask = 0x0;
        coin.physicsBody.contactTestBitMask = manCategory | invincibleManCategory;
        
        SKSpriteNode *coin2 = [[SKSpriteNode alloc] initWithTexture:coinTexture];
        coin2.size = CGSizeMake(55, 55);
        coin2.name = @"coin";
        coin2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:coin2.size];
        coin2.physicsBody.categoryBitMask = coinCategory;
        coin2.physicsBody.collisionBitMask = 0x0;
        coin2.physicsBody.contactTestBitMask = manCategory | invincibleManCategory;
        
        int r2 = arc4random()%3;
        if (r2 == 0){
            coin.position = CGPointMake(xpos1, yposCoin);
            coin2.position = CGPointMake(xpos2, yposCoin);
        }
        else if (r2 == 1){
            coin.position = CGPointMake(xpos2, yposCoin);
            coin.position = CGPointMake(xpos3, yposCoin);
        }
        else{
            coin.position = CGPointMake(xpos1, yposCoin);
            coin.position = CGPointMake(xpos3, yposCoin);
        }
        
        [self addChild:coin];
        [self addChild:coin2];
    }
    else{
        SKSpriteNode *coin = [[SKSpriteNode alloc] initWithTexture:coinTexture];
        coin.size = CGSizeMake(55, 55);
        coin.name = @"coin";
        coin.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:coin.size];
        coin.physicsBody.categoryBitMask = coinCategory;
        coin.physicsBody.collisionBitMask = 0x0;
        coin.physicsBody.contactTestBitMask = manCategory | invincibleManCategory;
        coin.position = CGPointMake(xpos1, yposCoin);
        
        SKSpriteNode *coin2 = [[SKSpriteNode alloc] initWithTexture:coinTexture];
        coin2.size = CGSizeMake(55, 55);
        coin2.name = @"coin";
        coin2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:coin2.size];
        coin2.physicsBody.categoryBitMask = coinCategory;
        coin2.physicsBody.collisionBitMask = 0x0;
        coin2.physicsBody.contactTestBitMask = manCategory | invincibleManCategory;
        coin2.position = CGPointMake(xpos2, yposCoin);
        
        SKSpriteNode *coin3 = [[SKSpriteNode alloc] initWithTexture:coinTexture];
        coin3.size = CGSizeMake(55, 55);
        coin3.name = @"coin";
        coin3.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:coin3.size];
        coin3.physicsBody.categoryBitMask = coinCategory;
        coin3.physicsBody.collisionBitMask = 0x0;
        coin3.physicsBody.contactTestBitMask = manCategory | invincibleManCategory;
        coin3.position = CGPointMake(xpos3, yposCoin);
        
        [self addChild:coin];
        [self addChild:coin2];
        [self addChild:coin3];
    }
}
// C inline function for generating numbers in parameter range
static inline float randomNumber(int high, int low)
{
    float f = (float)rand()/RAND_MAX;
    
    return low + f*(high-low);
}
// Color helper method that can use integers to create a color.
+(UIColor*)colorWithR:(CGFloat)r withG:(CGFloat)g withB:(CGFloat)b{
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
}

#pragma mark - Touch Control
// Method called by view that reacts when touches begin on the screen. If the game isnt started and the menu isnt showing the game is then started. If the game is not started and menu is showing the buttons are pressed or released. If the game is started and menu not showing the user moves to the desired side. If there is a two finger touch on the screen the user stays in the middle. This controls all animations
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.contentCreated)
        return;
    
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
        
        [tapButton runAction:[SKAction removeFromParent]];
        
        SKAction *genEvents = [SKAction sequence:@[[SKAction waitForDuration:eventGenDelay], [SKAction performSelector:@selector(generateSetOfEvents) onTarget:self]]];
        [self runAction:genEvents withKey:@"genSets"];
        numberOfEvents = 0;
        
    }
    else if (!self.tiltControls)
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
            [self.view presentScene:mainMenuScene];
        }
    }
    else if (!self.gameStarted||self.tiltControls)
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
