//
//  main.m
//  JSCocoaCurConv
//
//  Created by Giles Alexander on 7/12/11.
//  Copyright 2011 ThoughtWorks. All rights reserved.
//

#import <UIKit/UIKit.h>

#include "JavascriptCore-dlsym.h"
#include "JSCocoaController.h"

int main(int argc, char *argv[])
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
	// Fetch JS symbols
	[JSCocoaSymbolFetcher populateJavascriptCoreSymbols];
  
	// Load iPhone bridgeSupport
	[[BridgeSupportController sharedController] loadBridgeSupport:[NSString stringWithFormat:@"%@/iPhone.bridgesupport",  [[NSBundle mainBundle] bundlePath]]];
  // Load js class kit
	id c = [JSCocoaController sharedController];
  //	[c evalJSFile:[NSString stringWithFormat:@"%@/class.js", [[NSBundle mainBundle] bundlePath]]];
	// Load js bridge
	[c evalJSFile:[NSString stringWithFormat:@"%@/bridge.js", [[NSBundle mainBundle] bundlePath]]];

  int retVal = UIApplicationMain(argc, argv, nil, nil);
  [pool release];
  return retVal;
}
