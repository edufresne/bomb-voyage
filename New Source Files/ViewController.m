//
//  ViewController.m
//  Tylers app Revised
//
//  Created by Eric Dufresne on 2014-10-07.
//  Copyright (c) 2014 Eric Dufresne. All rights reserved.
//

#import "ViewController.h"
#import "MainMenuScene.h"
#import "AppDelegate.h"

// Private Variables for ads and boolean variables for purchase state and ad state
typedef enum : NSUInteger{
    iAd,
    AdMob
}AdType;
@interface ViewController ()
{
    AdType adType;
    ADBannerView *bannerView;
    BOOL adIsAllowed;
    BOOL adIsLoaded;
    BOOL purchased;
}
@property (strong, nonatomic) GADInterstitial *interstitial;
@property (strong, nonatomic) GADBannerView *backupBannerView;

@end

@implementation ViewController

//Methods that initialize the view controller//
#pragma mark - ViewController Initializer Methods

//Calls first when the view controller is loaded
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.screenName = @"Main Menu Screen";
}
- (void)viewDidLoad {
    // Seed number randomly generated to create psuedorandom numbers
    srand((unsigned int)time(NULL));
    
    //purchase state recieved from app delegate
    [super viewDidLoad];
    self.view.window.rootViewController = self;
    purchased = [(AppDelegate*)[UIApplication sharedApplication].delegate adsRemoved];
    if (!purchased)
        [self getProducts];
    // if adsRemoved is not purchased creates instance for interstitial as well as creates notification observers for gameplay
    if (!purchased)
    {
         [self createInterstitial];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleNotification:) name:@"hideAd" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleNotification:) name:@"showAd" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleNotification:) name:@"showInterstitial" object:nil];
    }
    
    //Preloads initialTextures for MainMenuScene and presents them on completion
    NSArray *array = [NSArray arrayWithObjects:[SKTextureAtlas atlasNamed:@"wideButton"], [SKTextureAtlas atlasNamed:@"smallButton"], nil];
    [SKTextureAtlas preloadTextureAtlases:array withCompletionHandler:^{
        MainMenuScene *scene = [[MainMenuScene alloc] initWithSize:self.view.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        scene.bigButtonAtlas = array[0];
        scene.smallButtonAtlas = array[1];
        SKView *view = (SKView*)self.originalContentView;
        [view presentScene:scene];
    }];
    if (!purchased)
    {
        adType = iAd;
        bannerView = [[ADBannerView alloc] initWithFrame:CGRectZero];
        bannerView.frame = CGRectOffset(bannerView.frame, 0, self.view.bounds.size.height-bannerView.frame.size.height);
        bannerView.delegate = self;
        bannerView.alpha = 0;
        adIsAllowed = YES;
        adIsLoaded = NO;
        [self.view addSubview:bannerView];
        
    }
}
//Hides status bar
-(BOOL)prefersStatusBarHidden{
    return YES;
}

// If bakup banner fails to recieve with error it will be hidden but ready incase it comes online again

// Methods called for first Ad banner and interstitial if IAP has not been purchased
#pragma mark - Ad Banner Methods

//Called if iAd fails to recieve add.
-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"IAD has Failed");
    if (adType == iAd)
        adIsLoaded = NO;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.1];
    [bannerView setAlpha:0];
    [UIView commitAnimations];
    
    [bannerView removeFromSuperview];
    [self createBackupBannerView];
}
//Called if iAd is successful. Shows ad if it is allowed
-(void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    NSLog(@"IAD has loaded");
    if (adType == iAd)
        adIsLoaded = YES;
    if (adIsAllowed)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        [bannerView setAlpha:1];
        [UIView commitAnimations];
    }
}
//General method for handling all ad related notifications sent by SKScenes. Depending on notification name the method will either hide banner ad, show banner ad, or present interstitial ad
-(void)handleNotification:(NSNotification*)notification
{
    if ([notification.name isEqualToString:@"showAd"])
    {
        adIsAllowed = YES;
        if (adIsLoaded)
        {
            if (adType == iAd){
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.5];
                [bannerView setAlpha:1];
                [UIView commitAnimations];
            }
            else{
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.5];
                [self.backupBannerView setAlpha:1];
                [UIView commitAnimations];
            }
            
        }
    }
    else if ([notification.name isEqualToString:@"hideAd"])
    {
        adIsAllowed = NO;
        if (adType == iAd){
            if (bannerView != nil)
            {
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.1];
                [bannerView setAlpha:0];
                [UIView commitAnimations];
            }
            else
            {
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.1];
                [bannerView setAlpha:0];
                [UIView commitAnimations];
            }
        }
        else{
            if (self.backupBannerView != nil)
            {
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.1];
                [self.backupBannerView setAlpha:0];
                [UIView commitAnimations];
            }
            else
            {
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.1];
                [self.backupBannerView setAlpha:0];
                [UIView commitAnimations];
            }
        }

    }
    else if ([notification.name isEqualToString:@"showInterstitial"])
    {
        [self showInterstitial];
    }
}
//Creates interstitial ad instance and loads request. Only lasts for one interstitial. Must be called on an as neede basis
-(void)createInterstitial{
    self.interstitial = [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-5566434891389365/3692627937"];
    self.interstitial.delegate = self;
    [self.interstitial loadRequest:[GADRequest request]];
}
// Presents interstitial ad from this viewcontroller
-(void)showInterstitial{
    if (self.interstitial.isReady)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.interstitial presentFromRootViewController:self];
        });
    }
}
// If interstitial cancel button is pressed it creates next interstitial so it is ready for the next call //
-(void)interstitialWillDismissScreen:(GADInterstitial *)ad{
    [self createInterstitial];
}
#pragma mark - Backup Banner Methods
-(void)createBackupBannerView{
    adType = AdMob;
    
    self.backupBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    self.backupBannerView.frame = CGRectOffset(self.backupBannerView.frame, 0, self.view.frame.size.height-self.backupBannerView.frame.size.height);
    self.backupBannerView.adUnitID = @"ca-app-pub-5566434891389365/3766664336";
    self.backupBannerView.delegate = self;
    self.backupBannerView.rootViewController = self;
    self.backupBannerView.alpha = 0;
    [self.backupBannerView loadRequest:[GADRequest request]];
    [self.view addSubview:self.backupBannerView];
}
-(void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error{
    adIsLoaded = NO;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.1];
    [self.backupBannerView setAlpha:0];
    [UIView commitAnimations];
}
-(void)adViewDidReceiveAd:(GADBannerView *)view{
    adIsLoaded = YES;
    if (adIsAllowed){
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:1];
        [self.backupBannerView setAlpha:1];
        [UIView commitAnimations];
    }
}
#pragma mark - Store Kit Methods
//Note: Methods are orginized in the order they will be called if a transaction occurs//

//Called in viewdidappear to retrieve SKProduct information from apple from SKProductsRequest
-(void)getProducts
{
    //canMakePayments = false if parental controls are on.
    if ([SKPaymentQueue canMakePayments])
    {
        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:@"BombVoyage.RemoveAds"]];
        request.delegate = self;
        [request start];
    }
}
//Called when information about product. If the array is returned with a product it will be set to the interface variable self.product
-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *array = [response products];
    // If array.count == 0 either an error in code or the setup of the in app purchase
    if (array.count == 0)
    {
        NSLog(@"Products Not Found, Invalid Product Identifiers: ");
        for (NSString *identifier in response.invalidProductIdentifiers)
        {
            //Displays all invalid product identifiers
            NSLog(@"%@", identifier);
        }
    }
    else
        self.product = [array objectAtIndex:0];
}
//Called by MainMenuScene if restore action is pressed by user and not already purchased
-(void)restoreInAppPurchase
{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}
//Called by MainMenuScene if the user wants to attempt a purchase
-(void)purchaseInAppPurchase
{
    SKPayment *payment = [SKPayment paymentWithProduct:self.product];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}
//Called everytime a change is made to a transacion that the user is currently in from the transaction observer. Acts depending on the state of the transaction
-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        SKPaymentTransactionState state = transaction.transactionState;
        //Transaction is finished if the state is either restored, purchased, or failed. Restored and purchased have same effect on gameplay //
        if (state == SKPaymentTransactionStateRestored||state == SKPaymentTransactionStatePurchased)
        {
            [self purchaseDoneWithTransitionState:state];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        }
        else if (state == SKPaymentTransactionStateFailed)
        {
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            // Shows different alertview depending on if the user cancelled or the transaction failed
            if (transaction.error.code == SKErrorPaymentCancelled)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Transaction Cancelled" message:nil delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
                [alertView show];
            }
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Transaction Failed" message:transaction.error.localizedFailureReason delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }
        
    }
}
//Called if transaction was purchased or restored. Changes boolean value of private view controller variable, delegate property and the saved value in NSUserDefaults. Calls adRemovalHasBeenPurchased.
-(void)purchaseDoneWithTransitionState:(SKPaymentTransactionState)state
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    delegate.adsRemoved = YES;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"adsRemoved"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    purchased = YES;
    [self adRemovalHasBeenPurchased];
    SKView *view = (SKView*)self.view;
    @try {
        MainMenuScene *scene = (MainMenuScene*)view.scene;
        SKNode *node = [scene childNodeWithName:@"removeAdsButton"];
        node.alpha = 0.5;
    }
    @catch (NSException *exception) {
        NSLog(@"User has switched to game scene");
    }
    
    // Shows different alertview depending on recieved state
    if (state == SKPaymentTransactionStateRestored)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"In App Purchases Restored" message:@"Ads removed" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
        [alertView show];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Purchase Successful" message:@"Ads removed" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
        [alertView show];
    }
}
// Called after all store kit procedures have been done. nils out all the ads, removes the notification observers for ad notifications and potentially catches the exception if they have already been removed or werent active
-(void)adRemovalHasBeenPurchased{
    self.interstitial = nil;
    [bannerView removeFromSuperview];
    bannerView = nil;
    
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:@"hideAd"];
        [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:@"showAd"];
        [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:@"showInterstitial"];
    }
    @catch (NSException *exception) {
        NSLog(@"One or more observers already deleted");
    }
}
#pragma mark - Game Kit
-(void)attemptAuthenticateForLeaderboard{
    
    NSLog(@"%i", [GKLocalPlayer localPlayer].isAuthenticated);
    if ([GKLocalPlayer localPlayer].isAuthenticated)
        [self showLeaderboard];
    else
    {
        AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        if (delegate.gameCenterViewController!=nil)
        {
            [self presentViewController:delegate.gameCenterViewController animated:YES completion:nil];
            NSLog(@"presentViewController");
            if ([GKLocalPlayer localPlayer].isAuthenticated)
                [self showLeaderboard];
        }
    }
}
-(void)showLeaderboard{
    GKGameCenterViewController *viewController = [[GKGameCenterViewController alloc] init];
    if (viewController!=nil)
    {
        viewController.gameCenterDelegate = self;
        viewController.viewState = GKGameCenterViewControllerStateLeaderboards;
        viewController.leaderboardIdentifier = @"BombVoyage.Leaderboard";
        NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:@"highScore"];
        GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:viewController.leaderboardIdentifier];
        score.value = (int64_t)number.integerValue;
        [self presentViewController:viewController animated:YES completion:nil];
        [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
            if (!error)
                NSLog(@"Reported Score");
            else
                NSLog(@"Error Reporting Scores: %@", error.localizedFailureReason);
        }];

    }
    
}
-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
