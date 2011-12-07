    //
//  RootViewController.m
//  DWMB
//
//  Created by Pete Hodgson on 7/8/11.
//  Copyright 2011 Pete Hodgson. All rights reserved.
//
#import "RootViewController.h"

#import "DWMBAppDelegate.h"

#import "StationsTVC.h"
#import "UpcomingDeparturesTVC.h"


#include "TargetConditionals.h"
#if TARGET_IPHONE_SIMULATOR

@interface CLLocationManager (Simulator)
@end

@implementation CLLocationManager (Simulator)

- (void) simulateLocationUpdate:(CLLocation *)newLocation{
    [self.delegate locationManager:self
               didUpdateToLocation:newLocation
                      fromLocation:newLocation];
}

-(void)startUpdatingLocation {
    CLLocation *westBerkeley = [[[CLLocation alloc] initWithLatitude:37.866881 longitude:-122.294803] autorelease];
    CLLocation *southABit = [[[CLLocation alloc] initWithLatitude:37.8446981345801 longitude:-122.26665258407593] autorelease];
	CLLocation *sfo = [[[CLLocation alloc] initWithLatitude:37.617112 longitude:-122.3831031] autorelease];
	
	[self performSelector:@selector(simulateLocationUpdate:) withObject:westBerkeley afterDelay:1.5];
	[self performSelector:@selector(simulateLocationUpdate:) withObject:sfo afterDelay:4.0];
}

@end

#endif // TARGET_IPHONE_SIMULATOR


@implementation RootViewController

- (IBAction) nearestTouched:(id)sender {
	if( _nearestStation ){
		UpcomingDeparturesTVC *upcomingDeparturesTVC = [[UpcomingDeparturesTVC alloc] init];
		[upcomingDeparturesTVC setSubjectStation:_nearestStation];
		[self.navigationController pushViewController:upcomingDeparturesTVC animated:YES];
		[upcomingDeparturesTVC release];		
	}
}

- (IBAction) selectTouched:(id)sender{
	StationsTVC *vc = [[StationsTVC alloc] init];
	[self.navigationController pushViewController:vc animated:YES];
	[vc release];
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


- (void)prepareGeolocation{
//	if( ![ CLLocationManager locationServicesEnabled] ){
//		// TODO: tell user location stuff not enabled
//		return;
//	}
	
	[_locationManager release];
	_locationManager = [[CLLocationManager alloc] init];
	_locationManager.delegate = self;
	NSLog(@"looking up location...");
	[_locationManager startUpdatingLocation];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationController.navigationBar.tintColor = BART_BLUE;
	
	[self prepareGeolocation];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	
	RELEASE_SAFELY(_locationManager);
	RELEASE_SAFELY(_locatingView);
	RELEASE_SAFELY(_geolocatedStationBtn);
}

- (void) viewWillAppear:(BOOL)animated{
	[self.navigationController setNavigationBarHidden:YES	animated:YES];
}

- (void) viewWillDisappear:(BOOL)animated{
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}


- (void)dealloc {
	[_nearestStation release];
    [super dealloc];
}


- (void) animateLocatingUIAway{
	CGPoint newCenter = CGPointMake(_locatingView.center.x, _locatingView.center.y-120);
	[UIView animateWithDuration:0.3
					 animations:^{ 
						 _locatingView.center = newCenter;
						 for (UIView *subview in [_locatingView subviews]) {
							 if( ![subview isKindOfClass:[UIImageView class]] ) //don't fade out the background image
								 subview.alpha = 0.0;
						 }
					 } 
					 completion:^(BOOL finished){
//						 [_locatingView setHidden:YES];
//						 [_locatingView setAlpha:1.0];
					 }];
}

#pragma mark CLLocationManagerDelegate implemenation
#pragma mark -

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation{
	NSLog( @"location updated: %@", newLocation );
	
	NSTimeInterval stalenessOfLocation = -[newLocation.timestamp timeIntervalSinceNow];
	NSLog( @"location is %f seconds old", stalenessOfLocation );
	if( stalenessOfLocation > 60*30 ){ //30 minutes
		NSLog(@"ignoring this location, it's too old");
		return;
	}
	 
	
	BOOL isFirstLocation = !_nearestStation;
	
	NSArray *stationsSortedByDistance = [[DWMBAppDelegate allStations] sortedArrayUsingComparator: ^(id lhs, id rhs) {
		CLLocationDistance lhsDistance = [newLocation distanceFromLocation:[(Station*)lhs location]];
		CLLocationDistance rhsDistance = [newLocation distanceFromLocation:[(Station*)rhs location]];
		
		if( lhsDistance > rhsDistance ) {
			return (NSComparisonResult)NSOrderedDescending;
		}else if( lhsDistance < rhsDistance ) {
			return (NSComparisonResult)NSOrderedAscending;
		}else{
			return NSOrderedSame;
		}
	}];
	
	[_nearestStation release];
	_nearestStation = [[stationsSortedByDistance objectAtIndex:0] retain];
	
	NSLog( @"nearest station is %@", [_nearestStation name] );
	
	[_geolocatedStationBtn setTitle:[_nearestStation name]
						   forState:UIControlStateNormal];

	if( isFirstLocation )
		[self animateLocatingUIAway];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
	if( status == kCLAuthorizationStatusAuthorized )
		[_locationManager startUpdatingLocation];
}

@end
