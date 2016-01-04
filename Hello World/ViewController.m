//
//  ViewController.m
//  Hello World
//
//  Created by Jacob Martin on 12/27/15.
//  Copyright © 2015 Jacob Martin. All rights reserved.
//

#import "ViewController.h"
#import "ServiceManager.h"

#import "Office.h"
#import <CoreData/CoreData.h>

#import "HelloAnnotation.h"
#import "HelloAnnotationView.h"



@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {

    
    
    [super viewDidLoad];
    

    
    _locationManager = [[CLLocationManager alloc] init]; // initializing locationManager
    
    
    
    
    //this check is for iOS 7
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]){
    [self.locationManager requestAlwaysAuthorization];
    }
    else{
        [CLLocationManager locationServicesEnabled];
    }

    _locationManager.delegate = self; // we set the delegate of locationManager to self.
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest; // setting the accuracy

    
    [_locationManager startUpdatingLocation];  //requesting location updates
//    [_locationManager startMonitoringSignificantLocationChanges];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    
    self.mapView.delegate = self;
    
    _detailView = [[[NSBundle mainBundle] loadNibNamed:@"DetailView" owner:self options:nil] objectAtIndex:0];
    _detailView.delegate = self;
    
    [self.view addSubview:_detailView];
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    _mapView.showsUserLocation = YES;
    
    self.hostReachability = [Reachability reachabilityWithHostName:@"www.apple.com"];
    [self.hostReachability startNotifier];
    
    

}

-(void)viewWillAppear:(BOOL)animated{
    [self refresh:nil];
}

- (void)viewDidUnload {
    self.fetchedResultsController = nil;
}
                 

- (void)refresh:(UIRefreshControl *)refreshControl {
    if (self.hostReachability.currentReachabilityStatus!=0) {
        [ServiceManager makeOfficesRequest];
    }
    else{
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSManagedObjectContext *context = [ServiceManager managedObjectContext];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Office" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        NSError *error = nil;
        NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
        
        if (error) {
            NSLog(@"Unable to execute fetch request.");
            NSLog(@"%@, %@", error, error.localizedDescription);
            
        } else {
            NSLog(@"%@", result);
            _cachedLocations = result;
            
            
            for (Office *office  in _cachedLocations) {
                HelloAnnotation *annotation = [[HelloAnnotation alloc] initWithOffice:office];
                [_mapView addAnnotation:annotation];
            }
            
        }
        
        [self sortLocations];
        [_tableView reloadData];
    }

    [refreshControl endRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark NSFetchedResultsController Methods
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *managedObjectContext = [ServiceManager managedObjectContext];
    
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Office" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"name" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:10];
    
   
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:managedObjectContext sectionNameKeyPath:nil
                                                                                   cacheName:@"Root"];
    _fetchedResultsController.delegate = self;
    
    
    return _fetchedResultsController;
    
}


//tess us that stuff has been added to core data store
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    _cachedLocations = [_fetchedResultsController fetchedObjects];
    for (Office *office  in _cachedLocations) {
        HelloAnnotation *annotation = [[HelloAnnotation alloc] initWithOffice:office];
        [_mapView addAnnotation:annotation];
    }
 
    [self sortLocations];
    [self.tableView reloadData];
    
}

#pragma mark Tableview Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count = [_cachedLocations count];
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OfficeCell" forIndexPath:indexPath];
    
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"OfficeCell"];
      
    }
    Office *office = [_cachedLocations objectAtIndex:indexPath.row];
    
  
    cell.textLabel.text = office.name;
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:[[office latitude] doubleValue] longitude:[[office longitude] doubleValue]];
    
    CLLocationDistance dist = [loc distanceFromLocation:_mapView.userLocation.location];
    
    if (dist == -1) {
        cell.detailTextLabel.text =  nil;
    }
    else{
        cell.detailTextLabel.text =  [NSString stringWithFormat:@"%@ mi",[self CLDistanceToMileString:dist]];
    }

    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self showDetailWithOffice:(Office*)[_cachedLocations objectAtIndex:indexPath.row]];
}




#pragma mark Mapview Delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    
    static NSString* myIdentifier = @"mapPin";
    HelloAnnotationView* pinView = (HelloAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:myIdentifier];
    
    if (!pinView)
    {
        pinView = [[HelloAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:myIdentifier];
        
    }
    return pinView;
}


- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    MKCoordinateRegion newRegion = mapView.region;
    CLLocationDegrees delta = newRegion.span.longitudeDelta;
   
    for (id<MKAnnotation> annotation in mapView.annotations){
        HelloAnnotationView* anView = (HelloAnnotationView*)[mapView viewForAnnotation: annotation];
        if (anView && ![annotation isKindOfClass:[MKUserLocation class]]){
          
            if(delta > 50.0){
                [anView.bubbleView animateFrameToFrame:CGRectMake(-7, -7, 14, 14)];
             }
            else if(delta > 10.0){
                [anView.bubbleView animateFrameToFrame:CGRectMake(-16, -16, 32, 32)];
            }
            else{
                [anView.bubbleView animateFrameToFrame:CGRectMake(-25, -25, 50, 50)];
            }


        }
    }
        
        NSLog(@"region changed");
    
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    HelloAnnotation *annotation = (HelloAnnotation*)view.annotation;
    [self showDetailWithOffice:annotation.office];
    
}

#pragma mark - Detail Delegate
//hide detail view with animation
-(void)viewDidReturn:(HelloDetailView *)detailView{
    [UIView animateWithDuration:2.0
                     animations:^{
                         
                         
                         MKCoordinateRegion region = _mapView.region;
                         region.span.latitudeDelta = 100;
                         region.span.longitudeDelta = 100;
                         
                         [_mapView setRegion:region animated:YES];
                     }
                     completion:^(BOOL finished){
                        
                         self.mapView.zoomEnabled = YES;
                         self.mapView.scrollEnabled = YES;
                         self.mapView.userInteractionEnabled = YES;
                         
                         
                     }];
    [UIView animateWithDuration:0.3
                     animations:^{
                         
                         CGRect frame = _tableView.frame;
                         CGRect detailFrame = _detailView.frame;
                         
                        
                             frame.origin.x = 0;
                             detailFrame.origin.x = frame.size.width;
                         
                         _tableView.frame = frame;
                         _detailView.frame = detailFrame;
                         
                         NSLog(@"%f",frame.origin.x);
                     }
                     completion:^(BOOL finished){
                    
                         
                         
                     }];

}


//get direction given detail view address

-(void)directionsRequested:(HelloDetailView *) detailView withAddress:(NSString*)address{
    Class mapItemClass = [MKMapItem class];
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
    {
        MKUserLocation *userLocation = _mapView.userLocation;
        BOOL locationAllowed = [CLLocationManager locationServicesEnabled];
        BOOL locationAvailable = userLocation.location!=nil;
        
        if (locationAllowed==NO) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Service Disabled"
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        } else {
            if (locationAvailable==NO){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Service Disabled"
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else{
                CLGeocoder *geocoder = [[CLGeocoder alloc] init];
                [geocoder geocodeAddressString:address
                             completionHandler:^(NSArray *placemarks, NSError *error) {
                                 
                                 // Convert the CLPlacemark to an MKPlacemark
                                 // Note: There's no error checking for a failed geocode
                                 CLPlacemark *geocodedPlacemark = [placemarks objectAtIndex:0];
                                 MKPlacemark *placemark = [[MKPlacemark alloc]
                                                           initWithCoordinate:geocodedPlacemark.location.coordinate
                                                           addressDictionary:geocodedPlacemark.addressDictionary];
                                 
                                 // Create a map item for the geocoded address to pass to Maps app
                                 MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
                                 [mapItem setName:geocodedPlacemark.name];
                                 
                                 // Set the directions mode to "Driving"
                                 // Can use MKLaunchOptionsDirectionsModeWalking instead
                                 NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
                                 
                                 // Get the "Current User Location" MKMapItem
                                 MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
                                 
                                 // Pass the current location and destination map items to the Maps app
                                 // Set the direction mode in the launchOptions dictionary
                                 [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem] launchOptions:launchOptions];
                                 
                             }];
            }

            }
        }
        
       }

#pragma mark - CoreLocation Delegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    [_locationManager stopUpdatingLocation];
    if (_previousLocation!=locations[0]) {
        
//        [self refresh:nil];
//        _previousLocation = locations[0];
//        
       
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Failed %ld",(long)[error code]);
    
}


#pragma mark - Other Method

//show the detail view with animation
-(void)showDetailWithOffice:(Office*)office{
    
    
    
    [UIView animateWithDuration:2.0
                     animations:^{
                         
                         Office *tappedOffice = office;
                         
                         CLLocation *loc = [[CLLocation alloc] initWithLatitude:[[office latitude] doubleValue] longitude:[[office longitude] doubleValue]];
                        
                         CLLocationDistance dist = [loc distanceFromLocation:_mapView.userLocation.location];
                         
                         
                         _detailView.office = tappedOffice;
                         if (dist == -1) {
                             _detailView.distance =  nil;
                            
                         }
                         else{
                              _detailView.distance =  [self CLDistanceToMileString:dist];
                         }
                         CLLocationDegrees lat = [tappedOffice.latitude floatValue];
                         CLLocationDegrees lon = [tappedOffice.longitude floatValue];
                         
                         MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance (CLLocationCoordinate2DMake(lat, lon), 40, 40);
                         
                         region.span.longitudeDelta = 0.016;
                         region.span.latitudeDelta = 0.016;
                         [_mapView setRegion:region animated:YES];
                     }
                     completion:^(BOOL finished){
                         
                         self.mapView.zoomEnabled = NO;
                         self.mapView.scrollEnabled = NO;
                         self.mapView.userInteractionEnabled = NO;
                         
                     }];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         
                         CGRect frame = _tableView.frame;
                         CGRect detailFrame = _detailView.frame;
                         NSLog(@"%f",frame.origin.x);
                         
                         frame.origin.x = -frame.size.width;
                         detailFrame.origin.x = 0;
                         
                         _tableView.frame = frame;
                         _detailView.frame = detailFrame;
                     }
                     completion:^(BOOL finished){
                         // whatever you need to do when animations are complete
                         
                         //[self setNeedsDisplay];
                         
                         
                         
                     }];
    
}

//convert distance from meters to miles
-(NSString*)CLDistanceToMileString:(CLLocationDistance)dist{

    CLLocationDistance meters = dist;
    //get distance in km
    CLLocationDistance kilometers = meters / 1000.0;
    //convert kilometers to miles
    float num=kilometers*0.62137;
    return [@(num) stringValue];
}


//sort locations by distance using a block
-(void)sortLocations{
    NSArray *sortedArray;
    sortedArray = [_cachedLocations sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        
        CLLocation *locA = [[CLLocation alloc] initWithLatitude:[[(Office*)a latitude] doubleValue] longitude:[[(Office*)a longitude] doubleValue]];
        CLLocation *locB = [[CLLocation alloc] initWithLatitude:[[(Office*)b latitude] doubleValue] longitude:[[(Office*)b longitude] doubleValue]];
        
        CLLocation *currentLocation = _mapView.userLocation.location;
        CLLocationDistance distA = [locA distanceFromLocation:currentLocation];
        CLLocationDistance distB = [locB distanceFromLocation:currentLocation];
        
        if ( distA < distB ) {
            return (NSComparisonResult)NSOrderedAscending;
        } else if ( distA > distB) {
            return (NSComparisonResult)NSOrderedDescending;
        } else {
            return (NSComparisonResult)NSOrderedSame;
        }
    }];
    
    _cachedLocations = sortedArray;
}


@end
