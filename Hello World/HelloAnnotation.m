//
//  HelloAnnotation.m
//  Hello World
//
//  Created by Jacob Martin on 12/27/15.
//  Copyright © 2015 Jacob Martin. All rights reserved.
//

#import "HelloAnnotation.h"

@implementation HelloAnnotation

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;

- (id)initWithOffice:(Office*)office
{
    self = [super init];
    if (self)
    {
      
        _office = office;
        CLLocationDegrees lat = [office.latitude floatValue];
        CLLocationDegrees lon = [office.longitude floatValue];
        coordinate = CLLocationCoordinate2DMake(lat, lon);
    }
    
    return self;
}

@end