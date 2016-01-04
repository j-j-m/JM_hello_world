//
//  HelloDetailView.h
//  Hello World
//
//  Created by Jacob Martin on 12/27/15.
//  Copyright © 2015 Jacob Martin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Office.h"

@class HelloDetailView;
@protocol HelloDetailViewDelegate <NSObject>
@optional
- (void)viewDidReturn:(HelloDetailView *) detailView;
- (void)directionsRequested:(HelloDetailView *) detailView withAddress:(NSString*)address;

@end

@interface HelloDetailView : UIView

@property (nonatomic, weak) id <HelloDetailViewDelegate> delegate;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *addressLabel;
@property (nonatomic, strong) IBOutlet UILabel *address2Label;
@property (nonatomic, strong) IBOutlet UILabel *distanceLabel;
@property (nonatomic, strong) IBOutlet UIButton *callButton;
@property (nonatomic, strong) IBOutlet UIButton *directionsButton;
@property (nonatomic, retain) Office* office;
@property (nonatomic, retain) NSString* phone;
@property (nonatomic, retain) NSString* address;
@property (nonatomic, retain) NSString* address2;
@property (nonatomic, retain) NSString* city;

@property (nonatomic,retain) NSString* distance;



-(IBAction)callOffice:(id)sender;


-(IBAction)toListView:(id)sender;

@end

