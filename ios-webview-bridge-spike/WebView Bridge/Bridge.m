//
//  Bridge.m
//  WebView Bridge
//
//  Created by Pete Hodgson on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Bridge.h"

@interface TargetAndSelector : NSObject {
    id _target;
    SEL _selector;
}
@end

@implementation TargetAndSelector

- (id)initWithTarget:(id)target andSelector:(SEL)selector {
    self = [super init];
    if (self) {
        _target = target;
        _selector = selector;
    }
    return self;
}

- (void) invokeWithArg:(id)arg{
    [_target performSelector:_selector withObject:arg];
}

@end

@interface Bridge(Private)
- (void) setupWebViewJavascript:(UIWebView *)webView;
@end

@implementation Bridge

- (id)init {
    self = [super init];
    if (self) {
        _invocationTargets = [[NSMutableDictionary alloc] init];
        _webView = [[UIWebView alloc] init];
        _webView.delegate = self;
        [self setupWebViewJavascript:_webView];
    }
    return self;
}

- (void)dealloc {
    [_invocationTargets release];
    [_webView release];
    [super dealloc];
}

- (void) loadAndEvaluateJavascript:(NSString *)fileName{
    NSString* pathToJS = [[NSBundle mainBundle] pathForResource:fileName ofType:@"js"];
    NSString *javascript = [NSString stringWithContentsOfFile:pathToJS usedEncoding:nil error:nil];  
    [_webView stringByEvaluatingJavaScriptFromString:javascript];
}

- (void) setupWebViewJavascript:(UIWebView *)webView {
    [self loadAndEvaluateJavascript:@"core"];
    [self loadAndEvaluateJavascript:@"app"];
}

- (void) handleInvocation:(NSString *)invocationName withObject:(id)target andSelector:(SEL)selector {
    TargetAndSelector *invocationTarget = [[TargetAndSelector alloc] initWithTarget:target andSelector:selector];
    [_invocationTargets setObject:invocationTarget forKey:invocationName];
    [target release];
}

- (void) invokeCallback:(NSString *)callback withParams:(NSDictionary *)params {
    NSString *paramsAsJson = [params yajl_JSONString];
    NSString *javascriptToInvoke = [NSString stringWithFormat:@"ramp.trigger( '%@', %@ );", callback, paramsAsJson];
    [_webView stringByEvaluatingJavaScriptFromString:javascriptToInvoke];
}

- (BOOL)webView:(UIWebView *)theWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if( [request.URL.scheme isEqualToString:@"about"] ){
        return YES;
    }
    
    if( [request.URL.scheme isEqualToString:@"http"] && [request.URL.host isEqualToString:@"bat.thoughtworks.com"] ){
        NSString *targetName = [request.URL.pathComponents objectAtIndex:1];
        NSString *paramsJson = [request.URL.query stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *params = [paramsJson yajl_JSON];
        
        TargetAndSelector *invocation = [_invocationTargets objectForKey:targetName];
        [invocation invokeWithArg:params];

    }else{
        NSLog(@"Strange? got a request to load a non-bat url:%@",request.URL);
        Debugger();
    }
    
    return NO;
}


@end
