//
//  BVConversionProduct.m
//  Store
//
//  Created by Eric Dufresne on 2015-03-26.
//  Copyright (c) 2015 Eric Dufresne. All rights reserved.
//

#import "BVConversionProduct.h"
#import "AppDelegate.h"

@implementation BVConversionProduct

-(id)initWithIdentifier:(NSString*)identifier{
    if (self = [super init])
    {
        //Fetch from core data with identifier
        AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        NSManagedObjectContext *context = delegate.managedObjectContext;
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"ConversionProduct" inManagedObjectContext:context];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(identifier = %@)", identifier];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setPredicate:predicate];
        [request setEntity:entity];
        NSError *error;
        
        NSArray *objects = [context executeFetchRequest:request error:&error];
        if (objects.count == 0)
        {
            //If no object was found treats it like a normal init call.
            self.identifier = identifier;
        }
        else if (objects.count == 2){
            //No two duplicates can be stored in core data or else an exception will be thrown.
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"Two or more objects with identifier: %@ saved in core data. One must be deleted in order to remove confusion", identifier] userInfo:nil];
        }
        else if (error)
            NSLog(@"%@", error.localizedFailureReason);
        else{
            //Retrieves attributes from core data
            NSManagedObject *object = [objects objectAtIndex:0];
            self.identifier = identifier;
            self.name = [object valueForKey:@"name"];
            NSNumber *number = [object valueForKey:@"coinValue"];
            self.coinValue = number.unsignedIntegerValue;
            number = [object valueForKey:@"cashValue"];
            self.cashValue = number.floatValue;
        }

    }
    return self;
}
+(instancetype)conversionProductWithIdentifier:(NSString*)identifier{
    return [[self alloc] initWithIdentifier:identifier];
}
-(void)save{
    //Fetch from core data with identifier
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ConversionProduct" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(identifier = %@)", self.identifier];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    [fetch setPredicate:predicate];
    [fetch setEntity:entityDescription];
    NSError *error;
    
    NSArray *objects = [context executeFetchRequest:fetch error:&error];
    if (objects.count == 0)
    {
        //If no objects will convert this object into an NSManagedObject and save it with the current properties.
        NSManagedObject *object = [[NSManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:context];
        [object setValue:self.identifier forKey:@"identifier"];
        [object setValue:self.name forKey:@"name"];
        [object setValue:[NSNumber numberWithFloat:self.cashValue] forKey:@"cashValue"];
        [object setValue:[NSNumber numberWithUnsignedInteger:self.coinValue] forKey:@"coinValue"];
        NSError *error2;
        [context save:&error2];
        if (error2)
            NSLog(@"%@", error.localizedFailureReason);
    }
    else if (objects.count == 1)
    {
        //Uses object that was fetched from core data and updates its properties
        NSManagedObject *object = [objects objectAtIndex:0];
        [object setValue:self.identifier forKey:@"identifier"];
        [object setValue:self.name forKey:@"name"];
        [object setValue:[NSNumber numberWithFloat:self.cashValue] forKey:@"cashValue"];
        [object setValue:[NSNumber numberWithUnsignedInteger:self.coinValue] forKey:@"coinValue"];
        NSError *error2;
        [context save:&error2];
        if (error2)
            NSLog(@"%@", error.localizedFailureReason);
    }
    else
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"Two or more objects with identifier: %@ saved in core data. One must be deleted in order to remove confusion", self.identifier] userInfo:nil];
    //Throws exception if duplicate core data objects with the same identifity are found.
}
@end
