#import "BaseUIViewController.h"
#import "JSCocoaController.h"
#import "TWBridgePageRegistry.h"

@implementation BaseUIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        handlers = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor =[UIColor whiteColor];
    label.text=self.navigationItem.title;  
    self.navigationItem.titleView = label;      
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (id)attachHandler:(NSString *)proxyId forEvent:(NSString *)event
{
    [handlers setValue:proxyId forKey:event];
    return self;
}

- (id)dispatchEvent:(NSString *)event withArgs:(NSArray *)args
{
  NSString *proxyId = [handlers objectForKey:event];
  if (proxyId) {
    NSMutableArray *eventDescriptor = [NSMutableArray arrayWithCapacity:2];
    [eventDescriptor addObject:proxyId];
    [eventDescriptor addObject:event];
    [eventDescriptor addObjectsFromArray:args];
    
    [[JSCocoa sharedController] callJSFunctionNamed:@"bridgeDispatch"
                                 withArgumentsArray:eventDescriptor];
  }
  return self;
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/
- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  [self performSelector:@selector(showNav) withObject:nil afterDelay:.01];
	
  [[TWBridgePageRegistry sharedRegistry] setCurrentPage:self];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
}

- (void)showNav
{
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)hideNav
{
	[self.navigationController setNavigationBarHidden:YES animated:YES];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"gradientBG.png"]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setTitle:(NSString *)title
{
    //[super setTitle:title];
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    //if (!titleView) {
    titleView = [[UILabel alloc] initWithFrame:CGRectZero];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.font = [UIFont fontWithName:@"Whitney-Medium" size:26];//[UIFont fontWithName:@"System-Bold" size:(25.0)];
    titleView.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    
    titleView.textColor = [UIColor whiteColor];
    
    self.navigationItem.titleView = titleView;
    //[titleView release];
    //}
    titleView.text = title;
    [titleView sizeToFit];
}

@end
