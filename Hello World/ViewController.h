//
//  ViewController.h
//  Hello World
//
//  Created by Jacob Martin on 12/27/15.
//  Copyright © 2015 Jacob Martin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#import "HelloDetailView.h"
#import "Reachability.h"

@interface ViewController : UIViewController <NSFetchedResultsControllerDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, HelloDetailViewDelegate>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) CLLocation *previousLocation;

@property (nonatomic, retain) NSArray *cachedLocations;
@property (nonatomic, retain) Office *focusedOffice;

@property (nonatomic) Reachability *hostReachability;



@property (nonatomic, retain) HelloDetailView *detailView;

@end

