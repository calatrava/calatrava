//
//  ViewController.h
//  WebView Bridge
//
//  Created by Pete Hodgson on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bridge.h"

@interface ViewController : UIViewController<UITextFieldDelegate>

@property (retain, nonatomic) IBOutlet UITextField *currencyInput;
@property (retain, nonatomic) IBOutlet UILabel *currencyOutput;

@property (retain, nonatomic) Bridge *bridge;
@property (retain, nonatomic) NSString *didTouchConvertCallback;

- (IBAction)didTouchConvert:(id)sender;

@end
