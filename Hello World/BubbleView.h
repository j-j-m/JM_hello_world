//
//  BubbleView.h
//  Hello World
//
//  Created by Jacob Martin on 12/27/15.
//  Copyright © 2015 Jacob Martin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BubbleView : UIView

@property (nonatomic, retain) UIImageView *imageView;

-(void)animateFrameToFrame:(CGRect)frame;
@end
