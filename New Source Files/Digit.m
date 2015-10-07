//
//  Digit.m
//  Tylers app Revised
//
//  Created by Eric Dufresne on 2014-10-10.
//  Copyright (c) 2014 Eric Dufresne. All rights reserved.
//

#import "Digit.h"

@interface Digit()
@property (nonatomic, readonly) NSMutableArray *setOfNumbers;
@property (nonatomic, readonly) SKTextureAtlas *atlas;
@end

@implementation Digit
@synthesize setOfNumbers, value, atlas;
-(id)initWIthBigNumbers:(BOOL)type withAlpha:(CGFloat)transparency withTextureAtlas:(SKTextureAtlas*)newAtlas
{
    if (self = [super init])
    {
        atlas = newAtlas;
        value = 0;
        setOfNumbers = [[NSMutableArray alloc]init];
        if (type)
        {
            for (int k = 0;k<=9;k++)
            {
                [setOfNumbers addObject:[atlas textureNamed:[NSString stringWithFormat:@"Big%i", k]]];
            }
            self.size = CGSizeMake(31, 48);
        }
        else
        {
            for (int k = 0;k<=9;k++)
            {
                [setOfNumbers addObject:[atlas textureNamed:[NSString stringWithFormat:@"Small%i", k]]];
            }
            self.size = CGSizeMake(16, 21);
        }
        
        SKAction *initializeTexure = [SKAction setTexture:[setOfNumbers objectAtIndex:0]];
        [self runAction:initializeTexure];
        self.alpha = transparency;
    }
    return self;
}

-(BOOL)increment
{
    value ++;
    if (self.alpha==0)
        self.alpha = 1;
    if (value <=9)
    {
        SKAction *updateImage = [SKAction setTexture:[setOfNumbers objectAtIndex:value]];
        [self runAction:updateImage];
        return YES;
    }
    return NO;
}
-(BOOL)setScore:(NSInteger)score
{
    if (score>9||score<0)
        return NO;
    value=score;
    SKAction *updateImage = [SKAction setTexture:[setOfNumbers objectAtIndex:score]];
    [self runAction:updateImage];
    return YES;
}
-(void)reset
{
    value = 0;
    SKAction *updateImage = [SKAction setTexture:[setOfNumbers objectAtIndex:0]];
    [self runAction:updateImage];
}

@end
