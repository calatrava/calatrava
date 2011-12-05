/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2011 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 * 
 * WARNING: This is generated code. Modify at your own risk and without support.
 */

#import <UIKit/UIKit.h>
#import "TiWindowProxy.h"

@protocol TiRootController
@required
-(void)manuallyRotateToOrientation:(UIInterfaceOrientation)orientation;

-(void)windowFocused:(UIViewController*)focusedViewController;
-(void)windowClosed:(UIViewController *)closedViewController;

-(CGRect)resizeView;
-(void)repositionSubviews;

-(void)setBackgroundColor:(UIColor*)color;
-(void)setBackgroundImage:(UIImage*) backgroundImage;

- (void)willHideViewController:(UIViewController *)focusedViewController animated:(BOOL)animated;
- (void)didHideViewController:(UIViewController *)focusedViewController animated:(BOOL)animated;
- (void)willShowViewController:(UIViewController *)focusedViewController animated:(BOOL)animated;
- (void)didShowViewController:(UIViewController *)focusedViewController animated:(BOOL)animated;

-(void)didKeyboardFocusOnProxy:(TiViewProxy<TiKeyboardFocusableView> *)visibleProxy;
-(void)didKeyboardBlurOnProxy:(TiViewProxy<TiKeyboardFocusableView> *)blurredProxy;

-(TiOrientationFlags)allowedOrientations;
-(BOOL)isTopWindow:(TiWindowProxy*)window;

@end
