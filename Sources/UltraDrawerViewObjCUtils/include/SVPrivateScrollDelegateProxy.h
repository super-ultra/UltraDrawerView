#import <UIKit/UIKit.h>

@interface SVPrivateScrollDelegateProxy : NSObject<UIScrollViewDelegate>

@property (nonatomic, weak) id mainDelegate;
@property (nonatomic, weak) id supplementaryDelegate;

@end
