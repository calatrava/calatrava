#import <Foundation/Foundation.h>

#include "JSCocoa.h"
#import "BaseUIViewController.h"


@interface TWBridgePageRegistry : NSObject
{
  UINavigationController *root;
    
  NSDictionary *pageFactories;
  NSMutableDictionary *pageProxyIds;
  NSMutableDictionary *pageObjects;
  
  BaseUIViewController *currentPage;
}

@property (nonatomic, retain) UINavigationController *root;
@property (nonatomic, retain) id currentPage;

+ (TWBridgePageRegistry *)sharedRegistry;

- (id)registerProxyId:(NSString *)proxyId forPageNamed:(NSString *)name;
- (id)attachHandler:(NSString *)proxyId forEvent:(NSString *)name;
- (id)valueForField:(NSString *)name onProxy:(NSString *)proxyId;
- (id)render:(JSValueRefAndContextRef)jsViewObject onProxy:(NSString *)proxyId;

- (id)displayWidget:(NSString *)name withOptions:(NSDictionary *)options;
- (void)displayDialog:(NSString *)dialogName;

- (id)registerPage:(id)page named:(NSString *)name;

- (id)changePage:(NSString *)target;

- (void)alert:(NSString *)message;
- (void)nslog:(NSString *)message;

- (void)openUrl:(NSString *)url;

- (void)startTimer:(NSString *)timerId timeout:(int)timeout;
- (id)invokeCallbackForWidget:(NSString *)widget withArgs:(NSArray *)arguments;

@end
