//
//  JSCocoaCurConvViewController.h
//  JSCocoaCurConv
//
//  Created by Giles Alexander on 7/12/11.
//  Copyright 2011 ThoughtWorks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JSCocoaCurConvViewController : UIViewController
{
  UITextField *startCurrencyField;
  IBOutlet UILabel *convertedCurrencyLabel;
  
  NSMutableDictionary *handlers;
}

@property (nonatomic, retain) IBOutlet UITextField *startCurrencyField;
@property (nonatomic, retain) IBOutlet UILabel *convertedCurrencyLabel;

- (id)attachHandler:(NSString *)proxyId forEvent:(NSString *)event;
- (id)dispatchEvent:(NSString *)event;
- (id)valueForField:(NSString *)field;
- (id)render:(NSString *)jsViewObject;

- (IBAction)convertCurrency:(id)sender;

@end
