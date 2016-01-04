//
//  BubbleView.m
//  Hello World
//
//  Created by Jacob Martin on 12/27/15.
//  Copyright © 2015 Jacob Martin. All rights reserved.
//

#import "BubbleView.h"

@implementation BubbleView

-(id)initWithFrame:(CGRect)frame{
    _imageView = [[UIImageView alloc] initWithFrame:frame];
    [_imageView setImage:[UIImage imageNamed:@"HelloLogo"]];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.alpha = 0;
    
    self = [super initWithFrame:frame];
    
    
    [self addSubview:_imageView];
    return self;
}
- (void)drawRect:(CGRect)rect {
    
    [self drawBubble:rect];
    
}


- (void)drawBubble: (CGRect)frame
{
  
    UIColor* color = [UIColor colorWithRed: 0 green: 0.533 blue: 0.78 alpha: 1];
    UIColor* color2 = [UIColor colorWithRed: 0.655 green: 0.655 blue: 0.655 alpha: 1];
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.06154 - 0.1) + 0.6, CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.05000 - 0.2) + 0.7, floor(CGRectGetWidth(frame) * 0.94615 - 0.1) - floor(CGRectGetWidth(frame) * 0.06154 - 0.1), floor(CGRectGetHeight(frame) * 0.93462 - 0.2) - floor(CGRectGetHeight(frame) * 0.05000 - 0.2))];
    [color2 setFill];
    [ovalPath fill];
    [color setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    frame.origin.x = 0;
    frame.origin.y = 0;
    [_imageView setFrame:frame];
    
    
}

#pragma mark animations


// animate frame to size
-(void)animateFrameToFrame:(CGRect)frame{
    
   
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         
                         if (30<frame.size.width) {
                             _imageView.alpha = 1.0;
                         }
                         else{
                             _imageView.alpha = 0.0;
                         }
                         self.frame = frame;
                         
                        // _imageView.frame = frame;
                     }
                     completion:^(BOOL finished){
                         // whatever you need to do when animations are complete
                         [self setNeedsDisplay];
                       
                     }];
    
    
}




@end
