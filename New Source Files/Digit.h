//
//  Digit.h
//  Tylers app Revised
//
//  Created by Eric Dufresne on 2014-10-10.
//  Copyright (c) 2014 Eric Dufresne. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Digit : SKSpriteNode
@property (nonatomic) NSInteger value;
-(void)reset;
-(BOOL)increment;
-(BOOL)setScore:(NSInteger)score;
-(id)initWIthBigNumbers:(BOOL)type withAlpha:(CGFloat)transparency withTextureAtlas:(SKTextureAtlas*)newAtlas;

@end
