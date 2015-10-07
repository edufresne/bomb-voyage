//
//  NewGameSceneIpad.h
//  New
//
//  Created by Eric Dufresne on 2014-12-21.
//  Copyright (c) 2014 Eric Dufresne. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface NewGameSceneIpad : SKScene <SKPhysicsContactDelegate>
@property NSInteger coinsCollected;
@property (strong, nonatomic) SKTextureAtlas *manAtlas;
@property (strong, nonatomic) SKTextureAtlas *arrowAtlas;
@property (strong, nonatomic) SKTextureAtlas *smallNumAtlas;
@property (strong, nonatomic) SKTextureAtlas *bigNumAtlas;
@end
