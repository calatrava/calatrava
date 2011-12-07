//
//  RootViewController.h
//  DWMB
//
//  Created by Pete Hodgson on 7/8/11.
//  Copyright 2011 Pete Hodgson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "Station.h"

@interface RootViewController : UIViewController<CLLocationManagerDelegate> {
	CLLocationManager *_locationManager;
	Station *_nearestStation;
	
	IBOutlet UIView* _locatingView;
	IBOutlet UIButton* _geolocatedStationBtn;
}

- (IBAction) nearestTouched:(id)sender;
- (IBAction) selectTouched:(id)sender;

@end
