//
//  ServiceManager.h
//  Hello World
//
//  Created by Jacob Martin on 12/27/15.
//  Copyright © 2015 Jacob Martin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@interface ServiceManager : NSObject

+(void)makeOfficesRequest;
+(void)fetchDataFromRecord:(NSManagedObject*)object withContext:(NSManagedObjectContext*)context;

+ (NSManagedObjectContext *)managedObjectContext;
@end
