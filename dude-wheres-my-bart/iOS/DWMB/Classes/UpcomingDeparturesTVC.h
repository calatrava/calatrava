//
//  UpcomingDeparturesTVC.h
//  DWMB
//
//  Created by Pete Hodgson on 7/6/11.
//  Copyright 2011 Pete Hodgson. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Station.h"

@interface UpcomingDeparturesTVC : UITableViewController {
	Station *_subjectStation;
	NSArray *_departures;
}

- (void) setSubjectStation:(Station *)station;

@end
