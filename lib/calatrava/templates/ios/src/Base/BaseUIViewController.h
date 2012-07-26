#import <UIKit/UIKit.h>

@interface BaseUIViewController : UIViewController{
    NSMutableDictionary *handlers;
}

- (id)attachHandler:(NSString *)proxyId forEvent:(NSString *)event;
- (id)dispatchEvent:(NSString *)event withArgs:(NSArray *)args;

@end
