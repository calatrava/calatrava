#import <UIKit/UIKit.h>

#import "CalatravaAppDelegate.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, CalatravaAppDelegate>
{
  int outstandingAjaxRequests;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *rootNavController;

@end
