//
//  TWBridgePageRegistry.h
//  iPhoneTest2
//
//  Created by Giles Alexander on 7/12/11.
//  Copyright 2011 ThoughtWorks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TWBridgePageRegistry : NSObject
{
  NSMutableDictionary *pages;
}

+ (TWBridgePageRegistry *)sharedRegistry;

- (id)registerPage:(id)page named:(NSString *)name;
- (id)pageWithName:(NSString *)pageName;

@end
