//
//  StoreViewController.h
//  Store
//
//  Created by Eric Dufresne on 2015-03-24.
//  Copyright (c) 2015 Eric Dufresne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "BVTierProduct.h"
#import "BVSkinProduct.h"
#import "BVConversionProduct.h"

//View controller that controls the whole store in a table view and manages completion of in app purchases
@interface StoreViewController : UITableViewController <SKProductsRequestDelegate, SKPaymentTransactionObserver>
//Products
@property (strong, nonatomic) NSMutableArray *passives;
@property (strong, nonatomic) NSMutableArray *skins;
@property (strong, nonatomic) NSMutableArray *powerups;
@property (strong, nonatomic) NSMutableArray *purchases;
//Displays current number of coins the user has in their purse.
@property (weak, nonatomic) IBOutlet UIBarButtonItem *coinItem;

//In app purchases fetched using StoreKit
@property (strong, nonatomic) NSMutableArray *skproducts;

//Back button
- (IBAction)dismissButton:(id)sender;

@end
