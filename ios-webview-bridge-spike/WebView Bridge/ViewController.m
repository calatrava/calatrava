//
//  ViewController.m
//  WebView Bridge
//
//  Created by Pete Hodgson on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
@synthesize webView;
@synthesize editorTextView;
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
    
    [webView release];
    webView = [[UIWebView alloc] init];
}

- (void)viewDidUnload
{
    [self setEditorTextView:nil];
    [self setCurrencyInput:nil];
    [self setCurrencyOutput:nil];
    [super viewDidUnload];
    
    // e.g. self.myOutlet = nil;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( editorTextView.isFirstResponder ){
        [editorTextView resignFirstResponder];
    }
    
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
    [webView release];
    [editorTextView release];
    [currencyInput release];
    [currencyOutput release];
    [bridge release];
    [didTouchConvertCallback release];
    [super dealloc];
}

- (IBAction)didTouchGoButton:(id)sender {
    [editorTextView resignFirstResponder];
    
    [bridge invokeCallback:@"testCallback" withParams:[NSDictionary dictionary]];
    
    NSString *js = editorTextView.text;
    NSString *result = [webView stringByEvaluatingJavaScriptFromString:js];
    if( [result isEqualToString:@""] )
        return;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"JS says"
                                                        message:result 
                                                       delegate:nil 
                                              cancelButtonTitle:@"Great, thanks for that." 
                                              otherButtonTitles:nil, nil];
    [alertView show];
    [alertView release];
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
