//
//  MainMenuScene.h
//  Tylers app Revised
//
//  Created by Eric Dufresne on 2014-10-12.
//  Copyright (c) 2014 Eric Dufresne. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

//Scene for starting menu.
@interface MainMenuScene : SKScene <UIActionSheetDelegate>
@property (strong, nonatomic) SKTextureAtlas *bigButtonAtlas;
@property (strong, nonatomic) SKTextureAtlas *smallButtonAtlas;
@end
