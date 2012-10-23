//
//  ConversionFormViewController.m
//  currencyConverter
//
//  Created by Giles Alexander on 7/26/12.
//  Copyright (c) 2012 ThoughtWorks. All rights reserved.
//

#import "ConversionFormViewController.h"

@interface ConversionFormViewController (){
  NSArray *_inCurrencyData; 
  NSArray *_outCurrencyData;
}

@property (retain, nonatomic) IBOutlet UIPickerView *outCurrencyPicker;
@property (retain, nonatomic) IBOutlet UIPickerView *inCurrencyPicker;

- (void)updateCurrencyPickerSelection:(UIPickerView *)pickerView usingData:(NSArray *)currencyData;
- (void)hideKeyboard;
@end

@implementation ConversionFormViewController
@synthesize outCurrencyPicker;
@synthesize inCurrencyPicker;
@synthesize inAmount;
@synthesize outAmount;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _inCurrencyData = [[NSArray alloc] init];
    _outCurrencyData = [[NSArray alloc] init]; 
  }
  return self; 
}

- (void)dealloc {
  [outCurrencyPicker release];
  [inCurrencyPicker release];
  [_inCurrencyData release];
  [_outCurrencyData release];
  [inAmount release];
  [outAmount release];
  [super dealloc];
}

-(void)viewDidLoad{
  [super viewDidLoad];
  inCurrencyPicker.delegate = self;
  inCurrencyPicker.dataSource = self;
  outCurrencyPicker.delegate = self;
  outCurrencyPicker.dataSource = self;
  [inCurrencyPicker reloadAllComponents];
  [outCurrencyPicker reloadAllComponents];
  [self updateCurrencyPickerSelection:inCurrencyPicker usingData:_inCurrencyData];
  [self updateCurrencyPickerSelection:outCurrencyPicker usingData:_outCurrencyData];
}

- (void)viewDidUnload
{
  [self setOutCurrencyPicker:nil];
  [self setInCurrencyPicker:nil];
  [self setInAmount:nil];
  [self setOutAmount:nil];
    [super viewDidUnload];
}

- (id)valueForField:(NSString *)field
{
  if ([field isEqualToString:@"in_currency"]) {
    return [[_inCurrencyData objectAtIndex:[inCurrencyPicker selectedRowInComponent:0]] objectForKey:@"code"];
  } else if ([field isEqualToString:@"out_currency"]) {
    return [[_outCurrencyData objectAtIndex:[outCurrencyPicker selectedRowInComponent:0]] objectForKey:@"code"];
  } else if ([field isEqualToString:@"in_amount"]) {
    return [inAmount text];
  }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)updateCurrencyPickerSelection:(UIPickerView *)pickerView usingData:(NSArray *)currencyData
{
  int i = -1;
  for (NSDictionary *currencyDetails in currencyData) {
    i++;
    if ([[currencyDetails objectForKey:@"selected"] boolValue])
    {
      [pickerView selectRow:i inComponent:0 animated:NO];
    }
  } 
}

- (void)hideKeyboard
{
  [inAmount resignFirstResponder];
}

- (void)renderCurrencyPicker:(UIPickerView *)pickerView usingData:(NSArray *)currencyData to:(NSArray **)pickerStore
{
  [*pickerStore release];
  *pickerStore = [currencyData copy];
  if( pickerView ){
    [pickerView reloadComponent:0];
    [self updateCurrencyPickerSelection:pickerView usingData:currencyData];
  }
}

- (IBAction)convert:(id)sender {
  [self hideKeyboard];
  [self dispatchEvent:@"convert" withArgs:@[]];
  return self;
}

- (void)render:(NSDictionary *)jsViewObject
{
  for (NSString *key in jsViewObject)
  {
    id value =  [jsViewObject objectForKey:key];
    if ([key isEqualToString:@"inCurrencies"]) {
      [self renderCurrencyPicker:inCurrencyPicker usingData:value to:&_inCurrencyData];
    } else if ([key isEqualToString:@"outCurrencies"]) {
      [self renderCurrencyPicker:outCurrencyPicker usingData:value to:&_outCurrencyData];
    } else if ([key isEqualToString:@"in_amount"]) {
      [outAmount setText:[NSString stringWithFormat:@"%@", [jsViewObject objectForKey:@"in_amount"]]];
    } else if ([key isEqualToString:@"out_amount"]) {
      [outAmount setText:[NSString stringWithFormat:@"%@", [jsViewObject objectForKey:@"out_amount"]]];
    }
  }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
  return 1;
}

- (NSArray *)currenciesForPicker:(UIPickerView *)picker{
  if( picker == self.inCurrencyPicker ){
    return _inCurrencyData;
  }else if( picker == self.outCurrencyPicker ){
    return _outCurrencyData;
  }else{
    return nil;
  }
}

- (NSDictionary *)currencyDetailsForPickerView:(UIPickerView *)pickerView atRow:(NSInteger)row{
  NSArray *currencies = [self currenciesForPicker:pickerView];
  if( !currencies )
    return nil;
  
  return [currencies objectAtIndex:row];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
  NSArray *currencies = [self currenciesForPicker:pickerView];
  if( currencies )
    return [currencies count];
  else
    return 0;
}

- (void)userSelectedCurrency:(NSDictionary *)details fromPicker:(UIPickerView *)picker
{
  NSString *event = picker == inCurrencyPicker ? @"selectedInCurrency" : @"selectedOutCurrency";
  
  NSString *currencyCode = [details objectForKey:@"code"];
  [self hideKeyboard];
  [self dispatchEvent:event withArgs:[NSArray arrayWithObject:currencyCode]];  
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
  NSDictionary *currencyDetails = [self currencyDetailsForPickerView:pickerView atRow:row];
  BOOL isValidSelection = [[currencyDetails objectForKey:@"enabled"] boolValue];
  
  if (isValidSelection) {
    [self userSelectedCurrency:currencyDetails fromPicker:pickerView];
  } else {
    int fallbackRow = (row == 0 ? row + 1 : row - 1);
    [pickerView selectRow:fallbackRow inComponent:component animated:YES];
    [self userSelectedCurrency:[self currencyDetailsForPickerView:pickerView atRow:fallbackRow] fromPicker:pickerView];
  }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
  NSDictionary *currencyDetails = [self currencyDetailsForPickerView:pickerView atRow:row];
  
  if (!view) {
    view = [[UILabel alloc] init];
  }
  
  UILabel *label = (UILabel *)view;
  [label setFrame:CGRectMake(9.0, 0.0, [pickerView frame].size.width - 40.0, 44.0)];
  [label setText:[currencyDetails objectForKey:@"code"]];
  [label setFont:[UIFont boldSystemFontOfSize:20.0]];
  [label setBackgroundColor:[UIColor clearColor]];
  [label setShadowColor:[UIColor whiteColor]];
  [label setOpaque:NO];
  [label setShadowOffset:CGSizeMake(1, 1)];
  if ([[currencyDetails objectForKey:@"enabled"] boolValue])
  {
    [label setTextColor:[UIColor blackColor]];
  } else {
    [label setTextColor:[UIColor lightGrayColor]];
  }
  return label;
}

@end
