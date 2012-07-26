//
//  AJAXConnection.h
//
//  Created by Rajdeep Kwatra on 07/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol AJAXConnectionDelegate <NSObject>
@required
- (void)receivedData:(NSString*)data from:(NSString *)requestId;
- (void)failedWithError:(NSError*)error from:(NSString *)requestId;
@end

@interface AJAXConnection : NSObject
{
    UINavigationController *root;
    NSString *reqId;
    NSMutableURLRequest *request;
    NSURLConnection *connection;
    NSTimer *requestTimer;
    
    NSMutableData *accumulatedData;
    
    id <AJAXConnectionDelegate> delegate;
}

@property (retain) id delegate;

- (AJAXConnection *)initWithRequestId:(NSString*)requestId url:(NSString *)url root:(UINavigationController *)root andHeaders:(NSDictionary *)headers;

- (id)setHttpMethod:(NSString*) method;
- (id)setHttpBody:(NSString*) httpBodyString;
- (void)execute;

@end
