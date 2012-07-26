#import <Foundation/Foundation.h>

@interface KernelBridge : NSObject

+ (void)startWith:(UINavigationController *)root;
+ (void)launch:(NSString *)flow;

@end
