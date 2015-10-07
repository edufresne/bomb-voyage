//
//  Man.h
//  Bomb Voyage
//
//  Created by Eric Dufresne on 2014-10-22.
//  Copyright (c) 2014 Eric Dufresne. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

//Sprite for the game character. Perloads sound and has dead or alive state as well as a position (left, middle or right)
@interface Man : SKSpriteNode
@property (readonly, nonatomic) SKAction *swipeSound;
@property NSInteger userPosition;
@property BOOL isAlive;

// Initializes with the texture atlas and sets the texture set to the current skin set selected in the store
-(id)initWithManAtlas:(SKTextureAtlas*)newAtlas;
//Movements caused by user
-(void)moveLeft;
-(void)moveRight;
-(void)moveCenter;
//Bag expand animation when coin or powerup is collected
-(void)expandBag;

//State change methods
-(void)kill;
-(void)restart;
@end
