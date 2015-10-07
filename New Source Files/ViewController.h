//
//  ViewController.h
//  Tylers app Revised
//
//  Created by Eric Dufresne on 2014-10-07.
//  Copyright (c) 2014 Eric Dufresne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <iAd/iAd.h>
#import <GameKit/GameKit.h>
#import "GAI.h"

@import GoogleMobileAds;

@interface ViewController : GAITrackedViewController <ADBannerViewDelegate, GADBannerViewDelegate, GADInterstitialDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver, GKGameCenterControllerDelegate>
@property (strong, nonatomic) SKProduct *product;
-(void)restoreInAppPurchase;
-(void)purchaseInAppPurchase;
-(void)attemptAuthenticateForLeaderboard;

/*
    ViewController does all work involving ad placement and visability plus observes for transactions and gets product information from apple. All iAd, AdMob, and StoreKit functionality is in ViewController which is retained until the app is exited or closed 
 */

@end

