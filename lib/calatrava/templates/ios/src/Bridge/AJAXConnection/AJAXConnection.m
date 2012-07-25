//
//  AJAXConnection.m
//
//  Created by Rajdeep Kwatra on 07/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AJAXConnection.h"
#define CONNECTION_TIMEOUT   30.0f
#define REQUEST_TIMEOUT      60.0f

@implementation AJAXConnection
@synthesize delegate;

- (AJAXConnection *)initWithRequestId:(NSString*)requestId url:(NSString *)url root:(UINavigationController *)root andHeaders:(NSDictionary *)headers
{
    NSLog(@"[CM] url: %@", url);
    self = [super init];
    if (self)
    {
        self->root = root;
        reqId = requestId;
        request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]
                                               cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                           timeoutInterval:CONNECTION_TIMEOUT];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSLog(@"HEADERS : %@", headers);
        for (id header in headers) {
          if (header == @"") {
            continue;
          }
          NSLog(@"%@ : %@", header, [headers objectForKey:header]);
          [request setValue:[headers objectForKey:header] forHTTPHeaderField:header];
        }
        accumulatedData = [[NSMutableData alloc] initWithCapacity:1000];
    }
    return self;
}

- (id)setHttpMethod:(NSString*)method
{
    [request setHTTPMethod:method];
    NSLog(@"[CM] httpMethod: %@", method);
    return self;
}

- (id)setHttpBody:(NSString*)httpBodyString
{
    [request setHTTPBody:[httpBodyString dataUsingEncoding:NSISOLatin1StringEncoding]];
    NSLog(@"[CM] PostData: %@",httpBodyString); 
    return self;
}

- (void)execute
{
    connection = [[NSURLConnection alloc] initWithRequest:request
                                                 delegate:self
                                         startImmediately:YES];
    requestTimer = [NSTimer scheduledTimerWithTimeInterval:REQUEST_TIMEOUT target:self selector:@selector(requestDidTimeout:) userInfo:nil repeats:NO];
}

- (void)requestDidTimeout:(id)sender {
  NSLog(@"connection request timed out");
  [[self delegate] failedWithError:nil from:reqId];
  [connection cancel];
}

#pragma mark NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
  [requestTimer invalidate];

  NSLog(@"Connection didReceiveResponse: %@ - %@", response, [response MIMEType]);
  NSInteger statusCode = [response statusCode];
  if (statusCode >= 400) {
    [[self delegate] failedWithError:nil from:reqId];
  }
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
  [requestTimer invalidate];
  NSLog(@"Connection didReceiveAuthenticationChallenge: %@", challenge);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  [accumulatedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  [requestTimer invalidate];
  NSLog(@"connection didFailWithError: %@", error);
  [[self delegate] failedWithError:error from:reqId];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  NSString *jsonString = [[NSString alloc] initWithData:accumulatedData encoding:NSUTF8StringEncoding];
  NSLog(@"Json Val: %@", jsonString);
  [[self delegate] receivedData:jsonString from:reqId];
}

@end
