#import <Foundation/Foundation.h>

@interface WidgetController : NSObject

+ (WidgetController *)sharedInstance;
- (void)presentWidget:(NSString *)name withOptions: (NSDictionary *) options withPresentingViewController: (UIViewController *) presentingViewController;

@end
