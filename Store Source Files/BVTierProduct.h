//
//  BVTierProduct.h
//  Store
//
//  Created by Eric Dufresne on 2015-03-25.
//  Copyright (c) 2015 Eric Dufresne. All rights reserved.
//

#import <Foundation/Foundation.h>

//Class used to create a product with a multi tierd price system. The first tier will be cheaper and each time the product is bought the price increases in coins until it has reached the 4th (max) teir.

@interface BVTierProduct : NSObject

// Name of the product in the store
@property (strong, nonatomic) NSString *name;

// Identifier unique in core data as well as image name for display picture in store
@property (strong, nonatomic) NSString *identifier;

// Array of prices that is in ascending order
@property (strong, nonatomic) NSMutableArray *prices;

// Different descriptions for each teir
@property (strong, nonatomic) NSMutableArray *descriptions;

// If the item has been fully purchased to max teir. Cannot be purchased if YES
@property (assign, nonatomic) BOOL purchased;

// Current teir number.
@property (assign, nonatomic) NSUInteger tierNumber;

// Init method with same implementation as BVConversionProduct
-(id)initWithIdentifier:(NSString*)identifier;
+(instancetype)tierProductWithIdentifier:(NSString*)identifier;
-(void)save;

//Advances current teir and checks if the item has been fully purchased
-(void)purchase;
// Gets current price out of array of prices and current teir advancement.
-(NSUInteger)currentPrice;
// Gets current Description out of array of prices and current teir advancement.
-(NSString*)currentDescription;
@end
