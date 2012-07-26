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
//  [[BridgeSupportController sharedController] loadBridgeSupport:[NSString stringWithFormat:@"%@/iPhone.bridgesupport",  bundle]];
  id c = [JSCocoaController sharedController];
  [c setUseJSLint:NO];
  // Load js libraries
  [c evalJSFile:[NSString stringWithFormat:@"%@/public/assets/scripts/underscore.js", bundle]];
    
  // Load js bridge
  [c evalJSFile:[NSString stringWithFormat:@"%@/public/assets/scripts/env.js", bundle]];
  [c evalJSFile:[NSString stringWithFormat:@"%@/public/assets/scripts/bridge.js", bundle]];
  NSString *loadFileText = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/public/assets/load_file.text", bundle]
                                                     encoding:NSASCIIStringEncoding
                                                        error:nil];
  NSArray *jsFiles = [loadFileText componentsSeparatedByString:@"\n"];
  for (NSString *jsFile in jsFiles) {
    [c evalJSFile:[NSString stringWithFormat:jsFile, bundle]];
  }
    
  [[TWBridgePageRegistry sharedRegistry] setRoot:root];
  [[TWBridgeURLRequestManager sharedManager] setRoot:root];
}

+ (void)launch:(NSString *)flow
{
  NSString *bundle = [[NSBundle mainBundle] bundlePath];
  id c = [JSCocoaController sharedController];
  [c evalJSString:flow];
}

@end
