#import "UIView+QZBShakeExtension.h"

@implementation UIView (QZBShakeExtension)

- (void)shakeView {
  [self shakeDirection:1 shakes:0];
}

- (void)shakeDirection:(int)direction shakes:(int)shakes {
  [UIView animateWithDuration:0.03
                   animations:^{
                     self.transform = CGAffineTransformMakeTranslation(5 * direction, 0);
                   }
                   completion:^(BOOL finished) {
                     if (shakes >= 10) {
                       self.transform = CGAffineTransformIdentity;
                       return;
                     }
                     __block int shakess = shakes;
                     shakess++;
                     __block int directionn = direction;
                     directionn = directionn * -1;
                     [self shakeDirection:directionn shakes:shakess];
                   }];
}

@end
