//
//  JSCocoaCurConvAppDelegate.h
//  JSCocoaCurConv
//
//  Created by Giles Alexander on 7/12/11.
//  Copyright 2011 ThoughtWorks. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JSCocoaCurConvViewController;

@interface JSCocoaCurConvAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet JSCocoaCurConvViewController *viewController;

@end
