//
//  ViewController.m
//  WebView Bridge
//
//  Created by Pete Hodgson on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
@synthesize currencyInput;
@synthesize currencyOutput;
@synthesize bridge;
@synthesize didTouchConvertCallback;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [bridge handleInvocation:@"conversionScreen.updateConversionResult" withObject:self andSelector:@selector(updateConversionResult:)];
}

- (void)viewDidUnload
{
    [self setCurrencyInput:nil];
    [self setCurrencyOutput:nil];
    [super viewDidUnload];
    
    // e.g. self.myOutlet = nil;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( currencyInput.isFirstResponder ){
        [currencyInput resignFirstResponder];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)dealloc {
    [currencyInput release];
    [currencyOutput release];
    [bridge release];
    [didTouchConvertCallback release];
    [super dealloc];
}

- (void)updateConversionResult:(NSDictionary *)params{
    NSString *currencyResult = [params objectForKey:@"currencyResult"];
    currencyOutput.text = currencyResult;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return NO;
}

- (IBAction)didTouchConvert:(id)sender {
    NSString *input = currencyInput.text;
    NSDictionary *params = [NSDictionary dictionaryWithObject:input forKey:@"inputCurrency"];
    [self.bridge invokeCallback:didTouchConvertCallback withParams:params];
}

@end
