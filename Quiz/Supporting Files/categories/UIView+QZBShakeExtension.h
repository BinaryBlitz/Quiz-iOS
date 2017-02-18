#import <UIKit/UIKit.h>

@interface UIView (QZBShakeExtension)

- (void)shakeView;
- (void)addDropShadowsForView;
- (void)addShadows;
- (void)addShadowsAllWay;
- (void)addShadowsAllWayRasterize;

-(void)addShadowsCategory;
- (UIView *) addShadowWithBackgroundCopy ;

@end
