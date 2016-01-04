//
//  ServiceManager.m
//  Hello World
//
//  Created by Jacob Martin on 12/27/15.
//  Copyright © 2015 Jacob Martin. All rights reserved.
//

#import "ServiceManager.h"
#import "NSString+Formatting.h"
#import "AppDelegate.h"

@implementation ServiceManager

// make web request and save to core data store
+(void)makeOfficesRequest{
    NSString *urlString = @"https://www.helloworld.com/helloworld_locations.json";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        NSManagedObjectContext *context = [self managedObjectContext];
        
        if (error)
        {
            if (![context save:&error]) {
                NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            }

        }
        else
        {
            NSError *jsonError;
            id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NULL error:&jsonError];
            if(jsonError) {
               
                NSLog(@"json error : %@", [jsonError localizedDescription]);
            } else {
                
            }
            
            
            NSArray *locationArray = [responseObject objectForKey:@"locations"];
            
            NSFetchRequest *officeFetch = [[NSFetchRequest alloc] init];
            [officeFetch setEntity:[NSEntityDescription entityForName:@"Office" inManagedObjectContext:context]];
            [officeFetch setIncludesPropertyValues:NO]; //only fetch the managedObjectID
            
            NSError *error = nil;
            NSArray *offices = [context executeFetchRequest:officeFetch error:&error];
            
            //error handling goes here
            for (NSManagedObject *office in offices) {
                [context deleteObject:office];
            }
            NSError *saveError = nil;
            [context save:&saveError];
            //more error handling here
            
            if (locationArray) {
                for (NSDictionary *dict in locationArray) {
                    
                    // Create a new managed object
                    NSManagedObject *newOffice = [NSEntityDescription insertNewObjectForEntityForName:@"Office" inManagedObjectContext:context];
                    for (NSString *key in dict.allKeys) {
                        [newOffice setValue:[dict valueForKey:key] forKey:key];
                    }
                   
                    // Save the object to persistent store
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSError *error = nil;
//                    if (![context save:&error]) {
//                        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
//                    }
//                    else{
//            
//                            AppDelegate *appDelegate  = [UIApplication sharedApplication].delegate;
//                            // appDelegate.managedObjectContext = context;
//                            [appDelegate saveContext];
                     
                        [self fetchDataFromRecord:newOffice withContext:context];
//                    }
                    });
                    
                }
                
            }
        }
    }];

}

//grab image data from record and finally save context
+(void)fetchDataFromRecord:(NSManagedObject*)object withContext:(NSManagedObjectContext*)context{
    
    NSString *resourceString = [object valueForKey:@"office_image"];
    
    if (resourceString) {
        if (![resourceString hasString:@"https"]) {
            resourceString = [resourceString stringByReplacingOccurrencesOfString:@"http" withString:@"https"];
        }
        
        
        NSURL *url = [NSURL URLWithString:resourceString];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
         {
  
             if (error)
             {
                 
             }
             else
             {

                 [object setValue:data forKey:@"image_data"];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     NSError *error = nil;
                     if (![context save:&error]) {
                         NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                     }
                     else{
                         AppDelegate *appDelegate  = [UIApplication sharedApplication].delegate;
                         [appDelegate saveContext];
                     }
                 });

             }
         }];

    
    }

}

// grab managed object context
+ (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    [context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy]; //we dont care about merge conflicts
    return context;
}


@end
