#import <Foundation/Foundation.h>

#import "AJAXConnection.h"

@interface TWBridgeURLRequestManager : NSObject<AJAXConnectionDelegate>
{
  NSMutableDictionary *outstandingConnections;
}

+ (TWBridgeURLRequestManager *)sharedManager;

@property (nonatomic, retain) UINavigationController *root;

- (id)requestFrom:(NSString *)requestId url:(NSString *)url as:(NSString *)method with:(NSString *)body andHeaders:(NSDictionary *)headers;

@end
