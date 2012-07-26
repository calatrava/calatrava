#import "TWBridgeURLRequestManager.h"

#include "JSCocoaController.h"

static TWBridgeURLRequestManager *bridge_instance = nil;

@implementation TWBridgeURLRequestManager

@synthesize root;

+ (TWBridgeURLRequestManager *)sharedManager
{
  if (!bridge_instance) {
    bridge_instance = [[TWBridgeURLRequestManager alloc] init];
  }
  return bridge_instance;
}

- (id)init
{
  self = [super init];
  if (self)
  {
    outstandingConnections = [NSMutableDictionary dictionaryWithCapacity:5];
  }
  return self;
}

- (id)requestFrom:(NSString *)requestId url:(NSString *)url as:(NSString *)method with:(NSString *)body andHeaders:(NSDictionary *)headers
{
  AJAXConnection *outgoing = [[AJAXConnection alloc] initWithRequestId:requestId url:url root:root andHeaders:headers];
  
  [outstandingConnections setObject:outgoing forKey:requestId];
  [outgoing setHttpMethod:method];
  if (body) {
    [outgoing setHttpBody:body];
  }
  [outgoing setDelegate:self];
  
  [outgoing execute];
  
  return self;
}

- (void)receivedData:(NSString*)data from:(NSString *)requestId
{
  [[JSCocoaController sharedController] callJSFunctionNamed:@"bridgeSuccessfulResponse"
                                              withArguments:requestId, data, nil];
  [outstandingConnections removeObjectForKey:requestId];
}

- (void)failedWithError:(NSError*)error from:(NSString *)requestId
{
  [[JSCocoaController sharedController] callJSFunctionNamed:@"bridgeFailureResponse"
                                              withArguments:requestId, [NSNumber numberWithInt:400], @"Failed.", nil];
  [outstandingConnections removeObjectForKey:requestId];
}

@end
