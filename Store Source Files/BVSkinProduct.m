//
//  BVSkinProduct.m
//  Store
//
//  Created by Eric Dufresne on 2015-03-25.
//  Copyright (c) 2015 Eric Dufresne. All rights reserved.
//

#import "BVSkinProduct.h"
#import "AppDelegate.h"

@implementation BVSkinProduct
-(id)initWithIdentifier:(NSString*)identifier{
    if (self = [super init])
    {
        AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = delegate.managedObjectContext;
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"SkinProduct" inManagedObjectContext:context];
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
        }
        else if (objects.count == 2)
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"Two or more objects with identifier: %@ saved in core data. One must be deleted in order to remove confusion", identifier] userInfo:nil];
        else if (error)
            NSLog(@"%@", error.localizedFailureReason);
        else{
            NSManagedObject *object = [objects objectAtIndex:0];
            self.identifier = identifier;
            self.name = [object valueForKey:@"name"];
            NSNumber *number = [object valueForKey:@"price"];
            self.price = number.unsignedIntegerValue;
            self.productDescription = [object valueForKey:@"productDescription"];
            self.purchased = [[object valueForKey:@"purchased"] boolValue];
        }
    }
    return self;
}
+(instancetype)skinProductWithIdentifier:(NSString*)identifier{
    return [[self alloc] initWithIdentifier:identifier];
}
-(void)purchase{
    self.purchased = YES;
}
-(void)save{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"SkinProduct" inManagedObjectContext:context];
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
        [object setValue:[NSNumber numberWithUnsignedInteger:self.price] forKey:@"price"];
        [object setValue:self.productDescription forKey:@"productDescription"];
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
        [object setValue:[NSNumber numberWithUnsignedInteger:self.price] forKey:@"price"];
        [object setValue:self.productDescription forKey:@"productDescription"];
        NSError *error2;
        [context save:&error2];
        if (error2)
            NSLog(@"%@", error.localizedFailureReason);
    }
    else
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"Two or more objects with identifier: %@ saved in core data. One must be deleted in order to remove confusion", self.identifier] userInfo:nil];
}
@end
