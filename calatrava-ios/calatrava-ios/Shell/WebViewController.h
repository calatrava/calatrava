#import <UIKit/UIKit.h>
#import "BaseUIViewController.h"

@interface WebViewController :  BaseUIViewController <UIWebViewDelegate>{
    
    UIWebView *_webView;
    NSDictionary *responseData;
    BOOL webViewReady;
}

@property(nonatomic, retain) IBOutlet UIWebView *_webView;

- (NSString *)pageName;

- (id)render:(id)jsViewObject;
- (id)valueForField:(NSString *)field;
- (id)bindEvent:(NSString *)event;

- (id)refreshWebView;
- (id)scrollToTop;

- (id)webViewReady;

- (void)displayDialog:(NSString *)dialogName;

@end
