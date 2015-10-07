//
//  Arrow.m
//  Bomb Voyage
//
//  Created by Eric Dufresne on 2014-11-10.
//  Copyright (c) 2014 Eric Dufresne. All rights reserved.
//

#import "Arrow.h"

@interface Arrow ()

@property (readonly, nonatomic) NSArray *textures;
@property (readonly, nonatomic) SKTextureAtlas *atlas;

@end

@implementation Arrow
@synthesize textures, atlas;

-(id)initRightArrowWithPosition:(CGPoint)pos withTextureAtlas:(SKTextureAtlas*)newAtlas
{
    if (self = [super init])
    {
        atlas = newAtlas;
        self.size = CGSizeMake(58, 51);
        self.position = pos;
        self.isPressed = NO;
        
        textures = [[NSArray alloc]initWithObjects:[atlas textureNamed:@"right_arrow"], [atlas textureNamed:@"right_arrow_pressed"], nil];
        [self setTexture:[textures objectAtIndex:0]];
    }
    return self;
}
-(id)initLeftArrowWithPosition:(CGPoint)pos withTextureAtlas:(SKTextureAtlas*)newAtlas;
{
    if (self = [super init])
    {
        atlas = newAtlas;
        self.size = CGSizeMake(58, 51);
        self.position = pos;
        self.isPressed = NO;

        textures = [[NSArray alloc] initWithObjects:[atlas textureNamed:@"left_arrow"], [atlas textureNamed:@"left_arrow_pressed"], nil];
        [self setTexture:[textures objectAtIndex:0]];
    }
    return self;
}
-(void)press
{
    self.isPressed = YES;
    [self setTexture:[textures objectAtIndex:1]];
}
-(void)reset
{
    self.isPressed = NO;
    [self setTexture:[textures objectAtIndex:0]];
}

@end
