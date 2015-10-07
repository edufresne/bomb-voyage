//
//  BVTierProduct.m
//  Store
//
//  Created by Eric Dufresne on 2015-03-25.
//  Copyright (c) 2015 Eric Dufresne. All rights reserved.
//

#import "BVTierProduct.h"
#import "AppDelegate.h"

@implementation BVTierProduct
-(id)initWithIdentifier:(NSString*)identifier{
    if (self = [super init])
    {
        AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = delegate.managedObjectContext;
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"TierProduct" inManagedObjectContext:context];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(identifier = %@)", identifier];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setPredicate:predicate];
        [request setEntity:entity];
        NSError *error;
        
        NSArray *objects = [context executeFetchRequest:request error:&error];
        if (objects.count == 0)
        {
            self.identifier = identifier;
            self.purchased = NO;
            self.tierNumber = 0;
        }
        else if (objects.count == 2)
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"Two or more objects with identifier: %@ saved in core data. One must be deleted in order to remove confusion", identifier] userInfo:nil];
        else if (error)
            NSLog(@"%@", error.localizedFailureReason);
        else{
            NSManagedObject *object = [objects objectAtIndex:0];
            self.identifier = identifier;
            self.name = [object valueForKey:@"name"];
            self.prices = [object valueForKey:@"prices"];
            self.descriptions = [object valueForKey:@"descriptions"];
            NSNumber *number = [object valueForKey:@"tierNumber"];
            self.tierNumber = number.unsignedIntegerValue;
            self.purchased = [[object valueForKey:@"purchased"] boolValue];
        }
    }
    return self;
}
+(instancetype)tierProductWithIdentifier:(NSString*)identifier{
    return [[self alloc] initWithIdentifier:identifier];
}
-(void)save{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"TierProduct" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(identifier = %@)", self.identifier];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    [fetch setPredicate:predicate];
    [fetch setEntity:entityDescription];
    NSError *error;
    
    NSArray *objects = [context executeFetchRequest:fetch error:&error];
    if (objects.count == 0)
    {
        NSManagedObject *object = [[NSManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:context];
        [object setValue:self.identifier forKey:@"identifier"];
        [object setValue:self.name forKey:@"name"];
        [object setValue:[NSNumber numberWithBool:self.purchased] forKey:@"purchased"];
        [object setValue:self.prices forKey:@"prices"];
        [object setValue:self.descriptions forKey:@"descriptions"];
        [object setValue:[NSNumber numberWithUnsignedInteger:self.tierNumber] forKey:@"tierNumber"];
        NSError *error2;
        [context save:&error2];
        if (error2)
            NSLog(@"%@", error.localizedFailureReason);
    }
    else if (objects.count == 1)
    {
        NSManagedObject *object = [objects objectAtIndex:0];
        [object setValue:self.identifier forKey:@"identifier"];
        [object setValue:self.name forKey:@"name"];
        [object setValue:[NSNumber numberWithBool:self.purchased] forKey:@"purchased"];
        [object setValue:self.prices forKey:@"prices"];
        [object setValue:self.descriptions forKey:@"descriptions"];
        [object setValue:[NSNumber numberWithUnsignedInteger:self.tierNumber] forKey:@"tierNumber"];
        NSError *error2;
        [context save:&error2];
        if (error2)
            NSLog(@"%@", error.localizedFailureReason);
    }
    else
         @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"Two or more objects with identifier: %@ saved in core data. One must be deleted in order to remove confusion", self.identifier] userInfo:nil];
}
-(NSString*)currentDescription{
    if (self.tierNumber==4)
        return [self.descriptions objectAtIndex:self.descriptions.count-1];
    return [self.descriptions objectAtIndex:self.tierNumber];
}
-(NSUInteger)currentPrice{
    if (self.tierNumber == 4)
        return 0;
    NSNumber *number = [self.prices objectAtIndex:self.tierNumber];
    return number.unsignedIntegerValue;
}
-(void)purchase{
    if(!self.purchased)
        self.tierNumber++;
    
    if (self.tierNumber==4)
        self.purchased = YES;
}
//Debug method
-(NSString*)description{
    NSString *string = [NSString stringWithFormat:@"Name: %@, Id: %@", self.name, self.identifier];
    if (self.purchased)
        string = [NSString stringWithFormat:@"%@\nPurchased: Yes", string];
    else
        string = [NSString stringWithFormat:@"%@\nPurchased: No", string];
    string = [NSString stringWithFormat:@"%@\nDescription: %@\nCurrent Price: %i\nTier Number: %i", string, [self currentDescription], (int)[self currentPrice], (int)self.tierNumber];
    return string;
}
@end
