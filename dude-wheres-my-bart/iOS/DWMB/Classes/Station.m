//
//  Station.m
//  DWMB
//
//  Created by Pete Hodgson on 7/6/11.
//  Copyright 2011 Pete Hodgson. All rights reserved.
//

#import "Station.h"
#import "GTMHTTPFetcher.h"
#import "DWMBAppDelegate.h"

@implementation Station
@synthesize abbr=_abbr,name=_name,location=_location;

+ (Station *) stationWithDictionary:(NSDictionary *)dict{
	return [[[Station alloc] initWithDictionary:dict] autorelease];
}

- (id) initWithDictionary:(NSDictionary *)dict
{
	if ((self = [super init])) {
		_name = [[dict objectForKey:@"name"]retain];
		_abbr = [[dict objectForKey:@"abbr"]retain];
		
		NSNumber *lat = [dict objectForKey:@"lat"]; 
		NSNumber *lon = [dict objectForKey:@"long"];
		_location = [[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lon doubleValue]];
	}
	return self;
}

- (void) dealloc
{
	[_name release];
	[_abbr release];
	[_location release];
	[super dealloc];
}

- (void) requestUpcomingDepartures:(void (^)(NSArray *departures))callback {
    NSString *urlString = [[[DWMBAppDelegate apiBaseUrl] stringByAppendingString:@"stations/"] stringByAppendingString:_abbr];
    
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	[request setValue:@"text/json" forHTTPHeaderField:@"Accept"];
	GTMHTTPFetcher* myFetcher = [GTMHTTPFetcher fetcherWithRequest:request];
	
	[myFetcher beginFetchWithCompletionHandler:^(NSData *retrievedData, NSError *error) {
		if (error != nil) {
			NSLog(@"Fail.\n%@",error);
			callback(nil);
		} else {			
			NSArray *departures = [retrievedData yajl_JSON];
			callback(departures);
		}
	}];
}


@end
