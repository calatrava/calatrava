#import "WidgetController.h"


static WidgetController *instance;

@implementation WidgetController

+(WidgetController *)sharedInstance{
  if(!instance) {
    instance = [[WidgetController alloc] init];
  }
  return instance;
}

-(void) presentWidget:(NSString *)name withOptions:(NSDictionary *)options withPresentingViewController:(UIViewController *)presentingViewController {
  // TODO
}

@end
