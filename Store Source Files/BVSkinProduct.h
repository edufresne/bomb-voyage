//
//  BVSkinProduct.h
//  Store
//
//  Created by Eric Dufresne on 2015-03-25.
//  Copyright (c) 2015 Eric Dufresne. All rights reserved.
//

#import <Foundation/Foundation.h>

//Class used to create a product in core data that represents a purchase of a skin.
@interface BVSkinProduct : NSObject

//Name that shows up in the store
@property (strong, nonatomic) NSString *name;
//Product description that shows up in the store that describes the product
@property (strong, nonatomic) NSString *productDescription;
//Product identifier that is unique identifier for core data and also is used as a property for the image name that wll be shown as a UIImage in the store
@property (strong, nonatomic) NSString *identifier;
//Price in coins for the item
@property (assign, nonatomic) NSUInteger price;
//Item can only be purchased once, if it is purchased the store will display that it has been purchased
@property (assign, nonatomic) BOOL purchased;

//Init methods, same implementation as BVSkinProduct
-(id)initWithIdentifier:(NSString*)identifier;
+(instancetype)skinProductWithIdentifier:(NSString*)identifier;
-(void)save;

//Encapsulates purchase, sets purchased to YES
-(void)purchase;
@end
