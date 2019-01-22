#import "SVPrivateScrollDelegateProxy.h"

@interface SVPrivateScrollDelegateProxy()

@property (nonatomic, strong, nullable) Class mainDelegateClass;
@property (nonatomic, strong, nullable) Class supplementaryDelegateClass;

@end

@implementation SVPrivateScrollDelegateProxy

- (void)setMainDelegate:(id)mainDelegate
{
    _mainDelegate = mainDelegate;
    self.mainDelegateClass = [mainDelegate class];
}

- (void)setSupplementaryDelegate:(id)supplementaryDelegate
{
    _supplementaryDelegate = supplementaryDelegate;
    self.supplementaryDelegateClass = [supplementaryDelegate class];
}

#pragma mark - NSObject

- (BOOL)respondsToSelector:(SEL)aSelector
{
    return [self.mainDelegate respondsToSelector:aSelector] || [self.supplementaryDelegate respondsToSelector:aSelector];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature* signature = [self.mainDelegateClass instanceMethodSignatureForSelector:selector];
    
    if (!signature) {
       signature = [self.supplementaryDelegateClass instanceMethodSignatureForSelector:selector];
    }
    
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    SEL aSelector = [anInvocation selector];

    if ([self.mainDelegate respondsToSelector:aSelector]) {
        [anInvocation invokeWithTarget:self.mainDelegate];
    }
    if ([self.supplementaryDelegate respondsToSelector:aSelector]) {
        [anInvocation invokeWithTarget:self.supplementaryDelegate];
    }
}

@end
