//
//  DWMBAppDelegate.h
//  DWMB
//
//  Created by Pete Hodgson on 7/6/11.
//  Copyright 2011 Pete Hodgson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DWMBAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
	
	NSDictionary *_stations;
    
    NSString *_apiBaseUrl;
}

+ (NSArray *) allStations;
+ (NSString *) apiBaseUrl;


@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@property (nonatomic, retain) NSString *apiBaseUrl;

- (NSArray *) allStations;

@end

