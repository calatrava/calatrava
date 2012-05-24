#import "Kiwi.h"
#import "TWBridgePageRegistry.h"

SPEC_BEGIN(TWBridgePageRegistryTest)
describe(@"TWBridgePageRegistry", ^{
    it(@"should provide a shared instance", ^{
        id sharedRegistry = [TWBridgePageRegistry sharedRegistry];

        [[sharedRegistry shouldNot] beNil];

        [[[TWBridgePageRegistry sharedRegistry] should] equal:sharedRegistry];
    });
});

SPEC_END
