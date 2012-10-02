//
//  ConversionFormViewController.h
//  currencyConverter
//
//  Created by Giles Alexander on 7/26/12.
//  Copyright (c) 2012 ThoughtWorks. All rights reserved.
//

#import "BaseUIViewController.h"

@interface ConversionFormViewController : BaseUIViewController<UIPickerViewDataSource, UIPickerViewDelegate>

@property (retain, nonatomic) IBOutlet UITextField *inAmount;
@property (retain, nonatomic) IBOutlet UITextField *outAmount;

- (IBAction)convert:(id)sender;
- (void)render:(NSDictionary *)jsViewObject;


@end
