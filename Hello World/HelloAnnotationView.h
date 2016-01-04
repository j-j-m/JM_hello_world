//
//  HelloAnnotationView.h
//  Hello World
//
//  Created by Jacob Martin on 12/27/15.
//  Copyright © 2015 Jacob Martin. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "BubbleView.h"

@interface HelloAnnotationView : MKAnnotationView
@property (nonatomic, assign) int badgeNumber;
@property (nonatomic, strong) BubbleView *bubbleView;

@end
