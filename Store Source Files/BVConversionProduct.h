//
//  BVConversionProduct.h
//  Store
//
//  Created by Eric Dufresne on 2015-03-26.
//  Copyright (c) 2015 Eric Dufresne. All rights reserved.
//

#import <Foundation/Foundation.h>

//Class used to create a product in core data that converts a cash value to a coin value and is displayed in the store.

@interface BVConversionProduct : NSObject
// Value of cash the user would pay
@property (assign, nonatomic) float cashValue;
// Value of coins recieved to the user for what they paid.
@property (assign, nonatomic) NSUInteger coinValue;
// Name of conversion in store
@property (strong, nonatomic) NSString *name;
// Unique identifier for all purchases, identifier can also be used to fetch previous data from core data. As well this is used to store image name for store display picture
@property (strong, nonatomic) NSString *identifier;

//Identifier method will create a new product if the identifier is not found already stored in core data, else will retrieve the previously created product from core data
-(id)initWithIdentifier:(NSString*)identifier;
//Static initializer
+(instancetype)conversionProductWithIdentifier:(NSString*)identifier;
//Saves to core data if changes have been made
-(void)save;
@end
