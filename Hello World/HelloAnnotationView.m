//
//  HelloAnnotationView.m
//  Hello World
//
//  Created by Jacob Martin on 12/27/15.
//  Copyright © 2015 Jacob Martin. All rights reserved.
//

#import "HelloAnnotationView.h"

@implementation HelloAnnotationView
@synthesize badgeNumber;



- (id)initWithAnnotation:(id)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // Compensate frame a bit so everything's aligned
//        [self setCenterOffset:CGPointMake(-9, -3)];
//        [self setCalloutOffset:CGPointMake(-2, 3)];
        
        // Add the pin icon
        _bubbleView = [[BubbleView alloc] initWithFrame:CGRectMake(-10,-10, 20, 20)];
        _bubbleView.opaque = NO;
        [self addSubview:_bubbleView];
        
    }
    return self;
}

@end
