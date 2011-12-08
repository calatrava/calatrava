//
//  Bridge.h
//  WebView Bridge
//
//  Created by Pete Hodgson on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Bridge : NSObject<UIWebViewDelegate>{
    UIWebView *_webView;
    NSMutableDictionary *_invocationTargets;
}

- (void) handleInvocation:(NSString *)invocationName withObject:(id)target andSelector:(SEL)selector;
- (void) invokeCallback:(NSString *)callback withParams:(NSDictionary *)params;

@end
