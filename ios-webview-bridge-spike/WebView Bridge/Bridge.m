//
//  Bridge.m
//  WebView Bridge
//
//  Created by Pete Hodgson on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Bridge.h"

@interface Bridge(Private)
- (void) setupWebViewJavascript:(UIWebView *)webView;
@end

@implementation Bridge

- (id)init {
    self = [super init];
    if (self) {
        _webView = [[UIWebView alloc] init];
        [self setupWebViewJavascript:_webView];
    }
    return self;
}

- (void)dealloc {
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
    
//    //TODO: TEMP TEST
//    [_webView stringByEvaluatingJavaScriptFromString:@"window.ramp.registerCallback( 'testCallback', function(){ window.alert('OH HAI'); });"];
}



- (void) invokeCallback:(NSString *)callback withParams:(NSDictionary *)params {
    NSString *paramsAsJson = [params yajl_JSONString];
    NSString *javascriptToInvoke = [NSString stringWithFormat:@"ramp.trigger( '%@', %@ );", callback, paramsAsJson];
    [_webView stringByEvaluatingJavaScriptFromString:javascriptToInvoke];
}


@end
