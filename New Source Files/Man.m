//
//  Man.m
//  Bomb Voyage
//
//  Created by Eric Dufresne on 2014-10-22.
//  Copyright (c) 2014 Eric Dufresne. All rights reserved.
//

#import "Man.h"

@interface Man ()
@property (readonly, nonatomic) SKTextureAtlas *atlas;
@property (strong, nonatomic) NSMutableArray *textureList;
@property (strong, nonatomic) NSMutableArray *deadTextureList;
@end

@implementation Man
@synthesize userPosition, textureList, deadTextureList, swipeSound, atlas;

-(id)initWithManAtlas:(SKTextureAtlas *)newAtlas
{
    if (self = [super init])
    {
        NSString *skinName = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedSkin"];
        NSString *prefix;
        atlas = newAtlas;
        if (!skinName||[skinName isEqualToString:@"normalSkin"])
            prefix = @"";
        else if ([skinName isEqualToString:@"beastModeSkin"])
            prefix = @"beast_";
        else if ([skinName isEqualToString:@"ninjaSkin"])
            prefix = @"ninja_";
        
        NSArray *baseNames = [NSArray arrayWithObjects:@"left_face", @"center_face", @"right_face", @"left_face_expanded", @"center_face_expanded", @"right_face_expanded", nil];
        NSArray *deadBaseNames = [NSArray arrayWithObjects:@"dead_dude", @"dead_dude_blink", nil];
        self.textureList = [[NSMutableArray alloc]init];
        self.deadTextureList = [[NSMutableArray alloc]init];
        
        for (NSString *name in baseNames){
            NSString *newName = [NSString stringWithFormat:@"%@%@", prefix, name];
            [self.textureList addObject:[atlas textureNamed:newName]];
        }
        for (NSString *name in deadBaseNames){
            NSString *newName = [NSString stringWithFormat:@"%@%@", prefix, name];
            [self.deadTextureList addObject:[atlas textureNamed:newName]];
        }
        
        swipeSound = [SKAction playSoundFileNamed:@"dudemoving.mp3" waitForCompletion:NO];
        userPosition = 1;
        self.size = CGSizeMake(130, 124);
        [self runAction:[SKAction setTexture:[textureList objectAtIndex:userPosition]]];
        self.isAlive = YES;
    }
    return self;
}

-(void)moveLeft
{
    if (userPosition == 0)
        return ;
    
    userPosition = 0;
    [self runAction:[SKAction setTexture:[textureList objectAtIndex:userPosition]]];
    [self runAction:swipeSound];
}
-(void)moveRight
{
    if (userPosition == 2)
        return ;
    userPosition = 2;
    [self runAction:[SKAction setTexture:[textureList objectAtIndex:userPosition]]];
    [self runAction:swipeSound];
}
-(void)moveCenter
{
    if (userPosition == 1)
        return;
    userPosition = 1;
    [self runAction:[SKAction setTexture:[textureList objectAtIndex:userPosition]]];
}
-(void)expandBag
{
    SKAction *expand = [SKAction sequence:@[[SKAction setTexture:[textureList objectAtIndex:userPosition+3]], [SKAction waitForDuration:0.1], [SKAction performSelector:@selector(revertBag) onTarget:self]]];
    [self runAction:expand];
}
-(void)revertBag
{
    if (self.isAlive)
        [self runAction:[SKAction setTexture:[textureList objectAtIndex:userPosition]]];
}

-(void)kill
{
    self.isAlive = NO;
    [self runAction:[SKAction setTexture:[deadTextureList objectAtIndex:0]]];
    SKAction *blink = [SKAction sequence:@[[SKAction waitForDuration:5], [SKAction setTexture:[deadTextureList objectAtIndex:1]], [SKAction waitForDuration:0.1], [SKAction setTexture:[deadTextureList objectAtIndex:0]]]];
    [self runAction:[SKAction repeatActionForever:blink] withKey:@"blink"];
}
-(void)restart
{
    self.isAlive = YES;
    [self removeActionForKey:@"blink"];
    userPosition = 1;
    [self runAction:[SKAction setTexture:[textureList objectAtIndex:userPosition]]];
}

@end
