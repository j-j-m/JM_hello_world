//
//  HelloDetailView.m
//  Hello World
//
//  Created by Jacob Martin on 12/27/15.
//  Copyright © 2015 Jacob Martin. All rights reserved.
//

#import "HelloDetailView.h"
#import "NSString+Formatting.h"

@implementation HelloDetailView


- (void)awakeFromNib {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    [self setFrame:CGRectMake(screenWidth, screenHeight/2, screenWidth, screenHeight/2)];
}

-(IBAction)toListView:(id)sender{
    if([self.delegate respondsToSelector:@selector(viewDidReturn:)]){
        [self.delegate viewDidReturn:self];
    }
}

-(void)setOffice:(Office *)office{
    UIImage *image = [UIImage imageWithData:[office image_data]];
    _phone = [office phone];
    _address = [office address];
    _address2 = [office address2];
    _city = [office city];
    
    [_imageView setImage:image];
    [_titleLabel setText:[office name]];
    [_callButton setTitle:[NSString stringWithFormat:@"Call %@",_phone] forState:UIControlStateNormal];
    [_addressLabel setText:_address];
    [_address2Label setText:_address2];
    
    
}

-(void)setDistance:(NSString*)distance{
    
    if (!distance) {
        [_distanceLabel setHidden:YES];
        [_directionsButton setHidden:YES];
    }
    else{
        [_distanceLabel setHidden:NO];
        [_directionsButton setHidden:NO];
        [_distanceLabel setText:[NSString stringWithFormat:@"%@ mi away", distance]];
    }
  //  [self setNeedsDisplay];
}

-(IBAction)callOffice:(id)sender{
   // NSString *phoneNumber = _office
   
    NSString *phoneCallNum = [NSString stringWithFormat:@"tel://%@", _phone.formatAsPhoneNumber];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneCallNum]];
    
    NSLog(@"Calling:  %@", phoneCallNum);
}


-(IBAction)getDirections:(id)sender{
    if([self.delegate respondsToSelector:@selector(directionsRequested:withAddress:)]){
        NSString *addressString = [NSString stringWithFormat:@"%@ %@ %@", _address, _address2, _city];
        [self.delegate directionsRequested:self withAddress:addressString];
    }
}




@end
