/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2011 by HelloAll, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 * 
 * WARNING: This is generated code. Modify at your own risk and without support.
 */
#ifdef USE_TI_FACEBOOK

#import "FacebookModule.h"
#import "KrollCallback.h"
#import "FBConnect/Facebook.h"

@interface TiFacebookRequest : NSObject<FBRequestDelegate2> {
	NSString *path;
	KrollCallback *callback;
	FacebookModule *module;
	BOOL graph;
}

-(id)initWithPath:(NSString*)path_ callback:(KrollCallback*)callback_ module:(FacebookModule*)module_ graph:(BOOL)graph_;

@end
#endif