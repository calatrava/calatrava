#import "KernelBridge.h"
#include "JSCocoaController.h"
#include "JavascriptCore-dlsym.h"
#include "TWBridgePageRegistry.h"
#include "TWBridgeURLRequestManager.h"

@implementation KernelBridge

+ (void)startWith:(UINavigationController *)root
{
  // Fetch JS symbols
  [JSCocoaSymbolFetcher populateJavascriptCoreSymbols];
    
  // Load iPhone bridgeSupport
  NSString *bundle = [[NSBundle mainBundle] bundlePath];
  [[BridgeSupportController sharedController] loadBridgeSupport:[NSString stringWithFormat:@"%@/iPhone.bridgesupport",  bundle]];
  id c = [JSCocoaController sharedController];
  [c setUseJSLint:NO];
  // Load js libraries
  [c evalJSFile:[NSString stringWithFormat:@"%@/public/assets/scripts/underscore.js", bundle]];
  [c evalJSFile:[NSString stringWithFormat:@"%@/public/assets/scripts/date.js", bundle]];
    
  // Load js bridge
  [c evalJSFile:[NSString stringWithFormat:@"%@/public/assets/scripts/env.js", bundle]];
  [c evalJSFile:[NSString stringWithFormat:@"%@/js/bridge.js", bundle]];
    
  [[TWBridgePageRegistry sharedRegistry] setRoot:root];
  [[TWBridgeURLRequestManager sharedManager] setRoot:root];
}

+ (void)launch:(NSString *)flow
{
  NSString *bundle = [[NSBundle mainBundle] bundlePath];
  id c = [JSCocoaController sharedController];
  [c evalJSString:@"calatrava.app.rootFeature().start()"];
}

@end
