/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2011 by HelloAll, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 * 
 * WARNING: This is generated code. Modify at your own risk and without support.
 */

#import "MGSplitView.h"
#ifdef USE_TI_UIIPADSPLITWINDOW

@implementation MGSplitView
@synthesize layingOut;

- (id)initWithFrame:(CGRect)frame controller:(MGSplitViewController*)controller_
{
    self = [super initWithFrame:frame];
    if (self) {
        controller = controller_;
        layingOut = NO;
        singleLayout = NO;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

-(void)setSingleLayout
{
    singleLayout = YES;
}

// Ugly hack to force the controller's layout method to be called whenever an initial
// layout request is made. We have to rely on the controller's layout method to properly
// set the 'layingOut' flag, as well... dangerous, and fragile.
-(void)layoutSubviews
{
    if (!layingOut && !singleLayout) {
        [controller layoutSubviewsForInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation] withAnimation:YES];
    }
    else {
        [super layoutSubviews];
        singleLayout = NO;
    }
}

@end

#endif
