#import "WidgetController.h"
#import "AirportViewController.h"
#import "DateViewController.h"

static WidgetController *instance;

@implementation WidgetController

+(WidgetController *)sharedInstance{
  if(!instance) {
    instance = [[WidgetController alloc] init];
  }
  return instance;
}

-(void) presentWidget:(NSString *)name withOptions:(NSDictionary *)options withPresentingViewController:(UIViewController *)presentingViewController {

  if([name isEqualToString:@"airport"]) {

    AirportViewController *widget = [AirportViewController sharedInstance];
    [widget setPresentViewController:presentingViewController];
    [widget presentView];
  } else if([name isEqualToString:@"date"]) {

    DateViewController *widget = [DateViewController sharedInstance];
    [widget setOptions:options];

    [presentingViewController.view addSubview:widget];
    [widget becomeFirstResponder];
  }
}

@end
