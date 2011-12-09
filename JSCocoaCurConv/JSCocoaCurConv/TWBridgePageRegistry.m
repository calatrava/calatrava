//
//  TWBridgePageRegistry.m
//  iPhoneTest2
//
//  Created by Giles Alexander on 7/12/11.
//  Copyright 2011 ThoughtWorks. All rights reserved.
//

#import "TWBridgePageRegistry.h"

#include "JSCocoaController.h"

static TWBridgePageRegistry *bridge_instance = nil;

@implementation TWBridgePageRegistry

+ (TWBridgePageRegistry *)sharedRegistry
{
  if (!bridge_instance) {
    bridge_instance = [[TWBridgePageRegistry alloc] init];
  }
  return bridge_instance;
}

- (id)init
{
  self = [super init];
  if (self) {
    pages = [NSMutableDictionary dictionaryWithCapacity:5];
    [[JSCocoa sharedController] evalJSFile:[NSString stringWithFormat:@"%@/bridge.js", [[NSBundle mainBundle] bundlePath]]];
  }
    
  return self;
}

- (id)registerPage:(id)page named:(NSString *)name
{
  [pages setValue:page forKey:name];
  return self;
}

- (id)pageWithName:(NSString *)pageName
{
  return [pages objectForKey:pageName];
}

@end
