//
//  NewGameScene.h
//  Bomb Voyage
//
//  Created by Eric Dufresne on 2014-10-27.
//  Copyright (c) 2014 Eric Dufresne. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <GameKit/GameKit.h>
#import <CoreMotion/CoreMotion.h>

@interface NewGameScene : SKScene <SKPhysicsContactDelegate>
@property NSInteger coinsCollected;
//Atlases that are preloaded and passed to the scene.
@property (strong, nonatomic) SKTextureAtlas *manAtlas;
@property (strong, nonatomic) SKTextureAtlas *arrowAtlas;
@property (strong, nonatomic) SKTextureAtlas *itemAtlas;

//Powerups that have been purchased from store
@property (strong, nonatomic) NSArray *powerupIdentifiers;
//Teir progress in passive powerups that store the identifier as well as a number between 0-4 depending on how many times the passive has been purchased
@property (strong, nonatomic) NSDictionary *passiveKeyVals;
@end
