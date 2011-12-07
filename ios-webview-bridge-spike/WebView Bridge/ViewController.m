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
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [self setEditorTextView:nil];
    [super viewDidUnload];
    
    // e.g. self.myOutlet = nil;
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
    [super dealloc];
}

- (IBAction)didTouchGoButton:(id)sender {
    [editorTextView resignFirstResponder];
    
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
@end
