//
//  JSCocoaCurConvViewController.m
//  JSCocoaCurConv
//
//  Created by Giles Alexander on 7/12/11.
//  Copyright 2011 ThoughtWorks. All rights reserved.
//

#import "JSCocoaCurConvViewController.h"

#include "JSCocoaController.h"
#include "TWBridgePageRegistry.h"

@implementation JSCocoaCurConvViewController
@synthesize startCurrencyField;
@synthesize convertedCurrencyLabel;

- (void)viewWillAppear:(BOOL)animated
{
  [[TWBridgePageRegistry sharedRegistry] registerPage:self named:@"CurrencyConverter"];
  handlers = [[NSMutableDictionary dictionaryWithCapacity:5] retain];
    
  [[JSCocoa sharedController] evalJSFile:[NSString stringWithFormat:@"%@/ccBoot.js", [[NSBundle mainBundle] bundlePath]]];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [self setStartCurrencyField:nil];
    [convertedCurrencyLabel release];
    convertedCurrencyLabel = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [startCurrencyField release];
    [convertedCurrencyLabel release];
    [super dealloc];
}

- (IBAction)convertCurrency:(id)sender
{
  NSLog(@"About to start converting.");
  for (int i = 0; i < 100000; ++i) {
    [self dispatchEvent:@"convertCurrency"];
  }
  NSLog(@"Finished converting.");
}

- (id)attachHandler:(NSString *)proxyId forEvent:(NSString *)event
{
  [handlers setValue:proxyId forKey:event];
  return self;
}

- (id)dispatchEvent:(NSString *)event
{
  NSString *proxyId = [handlers objectForKey:event];
  [[JSCocoa sharedController] callJSFunctionNamed:@"bridgeDispatch"
                                    withArguments:proxyId, event, nil];
  return self;
}

- (id)render:(id)jsViewObject
{
  id converted = [jsViewObject objectForKey:@"value"];
  [convertedCurrencyLabel setText:[NSString stringWithFormat:@"%@", converted]];
  return self;
}

- (id)valueForField:(NSString *)field
{
  if ([field isEqualToString:@"startCurrencyField"]) {
    id currValue = [NSNumber numberWithFloat:[[startCurrencyField text] floatValue]];
    return currValue;
  } else {
    return nil;
  }
}

@end
