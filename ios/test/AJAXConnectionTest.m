#import "Kiwi.h"
#import "AJAXConnection.h"

SPEC_BEGIN(AJAXConnectionSpec)

describe(@"AJAXConnection", ^{
    pending(@"should set request type", ^{
        id urlConnection = [NSURLConnection mock];
        id navController = [UINavigationController mock];
        
        NSString *connectionMethod = @"GET";
        NSString *connectionURL = @"http://example.com";
        AJAXConnection *connection = [[AJAXConnection alloc] initWithRequestId:@"testRequest" url:connectionURL root:navController];
        
        [connection setHttpMethod:connectionMethod];

        [connection execute];
    });
});

SPEC_END
