//
//  Station.h
//  DWMB
//
//  Created by Pete Hodgson on 7/6/11.
//  Copyright 2011 Pete Hodgson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Station : NSObject {
	NSString *_name;
	NSString *_abbr;
	CLLocation *_location;
}

@property (nonatomic,readonly) NSString *abbr;
@property (nonatomic,readonly) NSString *name;
@property (nonatomic,readonly) CLLocation *location;

+ (Station *) stationWithDictionary:(NSDictionary *)dict;

- (id) initWithDictionary:(NSDictionary *)dict;

- (void) requestUpcomingDepartures:(void (^)(NSArray *departures))callback;

@end

