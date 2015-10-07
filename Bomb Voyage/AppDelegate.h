//
//  AppDelegate.h
//  Bomb Voyage
//
//  Created by Eric Dufresne on 2015-01-14.
//  Copyright (c) 2015 Eric Dufresne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import <GameKit/GameKit.h>
#import <CoreData/CoreData.h>
#import <ChartBoost/ChartBoost.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, ChartboostDelegate>

@property (strong, nonatomic) UIWindow *window;
//Ads removed IAP boolean
@property (assign, nonatomic) BOOL adsRemoved;
//Stored view controller that will be presented if the user clicks on the leaderboards but the authentication was unsuccessful
@property (strong, nonatomic) UIViewController *gameCenterViewController;
//Various store parameters are stored in the app delegate for easier access in sprite kit
@property (strong, nonatomic) NSMutableArray *powerupIdentifiers;
@property (strong, nonatomic) NSMutableDictionary *passiveKeyVals;

//Authenticates users Game Center profile
-(void)authenticate;
//Gets purchase data from core data
-(void)retrievePurchaseData;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end

