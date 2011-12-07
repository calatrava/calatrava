//
//  ViewController.h
//  WebView Bridge
//
//  Created by Pete Hodgson on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (retain, nonatomic) IBOutlet UIWebView *webView;
@property (retain, nonatomic) IBOutlet UITextView *editorTextView;

- (IBAction)didTouchGoButton:(id)sender;

@end
