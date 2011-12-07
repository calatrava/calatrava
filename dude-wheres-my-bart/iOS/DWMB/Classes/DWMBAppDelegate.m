//
//  DWMBAppDelegate.m
//  DWMB
//
//  Created by Pete Hodgson on 7/6/11.
//  Copyright 2011 Pete Hodgson. All rights reserved.
//

#import "DWMBAppDelegate.h"
#import "RootViewController.h"

#import "Station.h"

@interface DWMBAppDelegate()

- (NSDictionary *) loadStationInfo;

@end


@implementation DWMBAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize apiBaseUrl=_apiBaseUrl;

+ (NSArray *) allStations {
	return [(DWMBAppDelegate *)[[UIApplication sharedApplication] delegate] allStations];
}

+ (NSString *) apiBaseUrl {
	return [(DWMBAppDelegate *)[[UIApplication sharedApplication] delegate] apiBaseUrl];        
}

- (NSArray *) allStations {
	return [[_stations allValues] sortedArrayUsingComparator: ^(id lhs, id rhs) {
		return [[(Station *)lhs name] compare:[(Station *)rhs name]];
	}]; 
}

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {   
    
    self.apiBaseUrl = @"http://dude-wheres-my-bart.heroku.com/";
    //"http://localhost:9393/"

	[_stations release];
    _stations = [[self loadStationInfo] retain];

    
    // Add the navigation controller's view to the window and display.
    [self.window addSubview:navigationController.view];
    [self.window makeKeyAndVisible];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}


- (NSDictionary *) loadStationInfo{
	NSString *file = [[NSBundle mainBundle] pathForResource:@"station_info" ofType:@"json"];
	NSData *data = [NSData dataWithContentsOfFile:file];
	NSDictionary *dict = [data yajl_JSON];
	
	NSMutableDictionary *stations = [NSMutableDictionary dictionary];
	for(NSString *abbr in dict){
		Station *station = [Station stationWithDictionary:[dict objectForKey:abbr]];
		[stations setObject:station
					 forKey:abbr];
	}
	return stations;
}

@end

