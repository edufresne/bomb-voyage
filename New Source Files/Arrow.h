//
//  Arrow.h
//  Bomb Voyage
//
//  Created by Eric Dufresne on 2014-11-10.
//  Copyright (c) 2014 Eric Dufresne. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

//Arrow sprite
@interface Arrow : SKSpriteNode

@property BOOL isPressed;

//Creates arrow that is pointing right, and a certain position and sends the texture atlas for changing state
-(id)initRightArrowWithPosition:(CGPoint)pos withTextureAtlas:(SKTextureAtlas*)newAtlas;
//Creates arrow that is pointing left, and a certain position and sends the texture atlas for changing state
-(id)initLeftArrowWithPosition:(CGPoint)pos withTextureAtlas:(SKTextureAtlas*)newAtlas;

//Changes textutre and state of sprite
-(void)press;
-(void)reset;
@end
