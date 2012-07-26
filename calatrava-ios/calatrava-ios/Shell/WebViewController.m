#import "WebViewController.h"
#import "WidgetController.h"

@interface WebViewController()
- (void)removeWebViewBounceShadow;
- (NSString *)convertWidgetNameToClassName:(NSString *)widgetName;
@end

@implementation WebViewController

@synthesize _webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      webViewReady = NO;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  [self._webView setDelegate:self];
  [self removeWebViewBounceShadow];

  NSString *bundle = [[NSBundle mainBundle] bundlePath];
  [self._webView loadRequest:[NSURLRequest requestWithURL:
                            [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/public/views/%@.html", bundle, [self pageName]]]]];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  NSLog(@"Dispatching pageOpened for page %@", [self pageName]);
  [self dispatchEvent:@"pageOpened" withArgs:[NSArray array]];
}

#pragma mark - Kernel methods

- (id)render:(id)jsViewObject {
    responseData = jsViewObject;
    NSLog(@"Response Data: %@", responseData);
    [self refreshWebView];
    return self;
}

- (id)valueForField:(NSString *)field {
  return [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.%@View.get('%@');", [self pageName], field]];
}

- (id)bindEvent:(NSString *)event
{
  NSString *jsCode = [NSString stringWithFormat:@"window.%@View.bind('%@', tw.batSignalFor('%@'));", [self pageName], event, event];
  [_webView stringByEvaluatingJavaScriptFromString:jsCode];
  return self;
}

- (void)displayDialog:(NSString *)dialogName
{
  [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.%@View.showDialog('%@');", [self pageName], dialogName]];
}

#pragma mark - Widget display
- (id)displayWidget:(NSString *)name withOptions:(NSDictionary *)options {

  WidgetController *widgetController = [WidgetController sharedInstance];
  [widgetController presentWidget:name withOptions:options withPresentingViewController:self]; 

  return self;
}

# pragma mark - WebView delegate methods

- (id)refreshWebView {
  if(responseData && webViewReady) {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseData options:kNilOptions error:nil];
    NSString *responseJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"Web data: %@", responseJson);
    NSLog(@"Page name: %@", [self pageName]);

    NSString *render = [NSString stringWithFormat:@"window.%@View.render(%@);", [self pageName], responseJson];
    [_webView stringByEvaluatingJavaScriptFromString:render];
    responseData = nil;
  }
  return self;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
  webViewReady = YES;
  [self webViewReady];

  [self refreshWebView];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    // Intercept custom location change, URL begins with "js-call:"
    NSString *requestString = [[request URL] absoluteString];
    if ([requestString hasPrefix:@"js-call:"]) {
      // Extract the event name and any arguments from the URL
      NSArray *eventAndArgs = [[requestString substringFromIndex:[@"js-call:" length]] componentsSeparatedByString:@"&"];
      NSString *event = [eventAndArgs objectAtIndex:0];
      NSMutableArray *args = [NSMutableArray arrayWithCapacity:[eventAndArgs count] - 1];
      for (int i = 1; i < [eventAndArgs count]; ++i) {
        NSString *decoded = [[[eventAndArgs objectAtIndex:i]
                              stringByReplacingOccurrencesOfString:@"+" withString:@" "]
                             stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [args addObject:decoded];
      }
      NSLog(@"Event: %@", event);

      [self dispatchEvent:event withArgs:args];

      // Cancel the location change
      return NO;
    }

    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return false;
    }
    return YES;
}

- (id)webViewReady {
  return self;
}

- (id)scrollToTop {
  [self._webView.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
  [self._webView.scrollView flashScrollIndicators];
  return self;
}

- (void)removeWebViewBounceShadow {
   if ([[_webView subviews] count] > 0)
    {
        for (UIView* shadowView in [[[_webView subviews] objectAtIndex:0] subviews])
        {
            [shadowView setHidden:YES];
        }
        // unhide the last view so it is visible again because it has the content
        [[[[[_webView subviews] objectAtIndex:0] subviews] lastObject] setHidden:NO];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSString *)convertWidgetNameToClassName:(NSString *)widgetName {
  return [widgetName stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[widgetName substringToIndex:1] uppercaseString]];
}

@end
