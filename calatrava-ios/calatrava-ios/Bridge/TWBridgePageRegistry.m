#import "TWBridgePageRegistry.h"
#include "JSCocoaController.h"

static TWBridgePageRegistry *bridge_instance = nil;

@interface TWBridgePageRegistry()
- (id)ensurePageWithProxyId:(NSString *)proxyId;
- (id)ensurePageWithName:(NSString *)target;
- (NSString *)convertPageNameToClassName:(NSString *)pageName;
@end

@implementation TWBridgePageRegistry

@synthesize root, currentPage;

+ (TWBridgePageRegistry *)sharedRegistry
{
  if (!bridge_instance)
  {
    bridge_instance = [[TWBridgePageRegistry alloc] init];
  }
  return bridge_instance;
}

- (id)init
{
  self = [super init];
  if (self)
  {
    pageProxyIds = [NSMutableDictionary dictionaryWithCapacity:8];
    pageObjects  = [NSMutableDictionary dictionaryWithCapacity:8];
  }
  
  return self;
}

- (id)registerProxyId:(NSString *)proxyId forPageNamed:(NSString *)name
{
  [pageProxyIds setObject:[self convertPageNameToClassName:name] forKey:proxyId];
  return self;
}

- (id)attachHandler:(NSString *)proxyId forEvent:(NSString *)name
{
  id pageObject = [self ensurePageWithProxyId:proxyId];
  
  [pageObject attachHandler:proxyId forEvent:name];
  return self;
}

- (id)valueForField:(NSString *)name onProxy:(NSString *)proxyId
{
  BaseUIViewController *pageObject = [self ensurePageWithProxyId:proxyId];
  
  return [pageObject valueForField:name];
}

- (id)render:(JSValueRefAndContextRef)jsViewObject onProxy:(NSString *)proxyId
{
  BaseUIViewController *pageObject = [self ensurePageWithProxyId:proxyId];
  
  NSObject* objectFromJavascript = nil;
  [JSCocoaFFIArgument unboxJSValueRef:jsViewObject.value
                             toObject:&objectFromJavascript
                            inContext:jsViewObject.ctx];
  
  [pageObject render:(NSDictionary *)objectFromJavascript];
  return self;
}

- (id)displayWidget:(NSString *)name withOptions:(NSDictionary *)options {
  id currentViewController = [root topViewController];
  [currentViewController displayWidget:name withOptions:options];

  return self;
}

- (id)invokeCallbackForWidget:(NSString *)widget withArgs:(NSArray *)arguments {
  NSMutableArray *_args = [[NSMutableArray alloc] init];
  [_args addObject:widget];
  [_args addObjectsFromArray:arguments];
  [[JSCocoa sharedController] callJSFunctionNamed:@"bridgeInvokeCallback"
                               withArgumentsArray:_args];

  return self;
}

- (id)registerPage:(id)page named:(NSString *)name
{
  [pageObjects setObject:page forKey:name];
  return self;
}

- (id)changePage:(NSString *)target
{
    NSLog(@"Change Page to: %@", target);
    currentPage = [self ensurePageWithName:target];

    [currentPage scrollToTop];

    if([[root viewControllers] containsObject:currentPage]) {
        [root popToViewController:currentPage animated:YES];
    } else{
        [root pushViewController:currentPage animated:YES];
    }

    return self;
}

- (void)alert:(NSString *)message
{
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
  [alert show];
}

- (void)nslog:(NSString *)message
{
  NSLog(@"Bridge log: %@", message);
}

- (void)openUrl:(NSString *)url
{
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)timerFired:(NSTimer*)theTimer
{
  NSString *timerId = (NSString *)[theTimer userInfo];
  NSLog(@"Firing timer %@", timerId);
  [[JSCocoaController sharedController] callJSFunctionNamed:@"bridgeFireTimer"
                                              withArguments:timerId, nil];
}

- (void)startTimer:(NSString *)timerId timeout:(int)timeout
{
  [NSTimer scheduledTimerWithTimeInterval:timeout
                                   target:self
                                 selector:@selector(timerFired:)
                                 userInfo:timerId
                                  repeats:NO];
}

- (void)displayDialog:(NSString *)dialogName
{
  NSLog(@"Displaying dialog %@", dialogName);
  [currentPage displayDialog:dialogName];
}

- (id)ensurePageWithProxyId:(NSString *)proxyId
{
  return [self ensurePageWithName:[pageProxyIds objectForKey:proxyId]];
}

- (id)ensurePageWithName:(NSString *)pageName
{
  NSLog(@"pageName: %@", pageName);
  pageName = [self convertPageNameToClassName:pageName];
  NSLog(@"capitalized pageName: %@", pageName);
  
  id page = [pageObjects objectForKey:pageName];
  NSLog(@"page: %@", page);
  
  if (!page)
  {
    NSString *viewControllerName = [pageName stringByAppendingString:@"ViewController"];
    id factory = NSClassFromString(viewControllerName);
    NSLog(@"VC: %@", viewControllerName);
    page = [[factory alloc] initWithNibName:nil bundle:nil];
    [pageObjects setObject:page forKey:pageName];
  }
  
  return page;
}

- (NSString *)convertPageNameToClassName:(NSString *)pageName {
  return [pageName stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[pageName substringToIndex:1] uppercaseString]];
}
@end
