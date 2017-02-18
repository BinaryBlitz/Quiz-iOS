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

- (void)addDropShadowsForView {

  UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,
      -10,
      CGRectGetWidth([UIScreen
          mainScreen].bounds),
      10)];

  view.backgroundColor = [UIColor clearColor];
  self.clipsToBounds = YES;
  //self.layer.masksToBounds = YES;
  view.layer.masksToBounds = NO;
  view.layer.shadowOffset = CGSizeMake(0.0f, 4.0f);
  view.layer.shadowColor = [[UIColor blackColor] CGColor];
  view.layer.shadowRadius = 5;
  view.layer.shadowOpacity = .4;

  [view.layer setShadowPath:[UIBezierPath
      bezierPathWithRect:view.bounds].CGPath];

  [self addSubview:view];
}

- (void)addShadows {
  self.layer.shadowColor = [UIColor lightGrayColor].CGColor;
  self.layer.shadowOffset = CGSizeMake(2.0, 2.0);
  self.layer.shadowRadius = 2.0;
  self.layer.shadowOpacity = 0.5;

//    self.layer.shouldRasterize = YES;
//    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

- (void)addShadowsAllWay {

  //  UIBezierPath *shadowPath  = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 300, 30) cornerRadius:10];
  self.layer.shadowColor = [UIColor blackColor].CGColor;
  self.layer.shadowOffset = CGSizeMake(0.0, 0.0);
  self.layer.shadowRadius = 4.0;
  self.layer.shadowOpacity = 0.7;

  //self.layer.shouldRasterize = YES;
  //  self.layer.rasterizationScale =  [UIScreen mainScreen].scale;
  // self.layer.masksToBounds = NO;
  // [self.layer setShadowPath:shadowPath.CGPath];

  //  self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.frame byRoundingCorners:self.layer.cornerRadius cornerRadii:(CGSize)]
//
  //  UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.layer.bounds];
//    self.layer.masksToBounds = NO;
//    self.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
//    self.layer.shadowOpacity = 0.5f;

  CGPathRef path = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
  self.layer.shadowPath = path;
}

- (void)addShadowsAllWayRasterize {

  self.layer.shadowColor = [UIColor blackColor].CGColor;
  self.layer.shadowOffset = CGSizeMake(0.0, 0.0);
  self.layer.shadowRadius = 4.0;
  self.layer.shadowOpacity = 0.7;
  self.layer.shouldRasterize = YES;
  self.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

- (UIView *)addShadowWithBackgroundCopy {
  UIView *backView = [[UIView alloc] initWithFrame:self.frame];
  UIBezierPath *path = [UIBezierPath bezierPathWithRect:backView.bounds];
  backView.layer.masksToBounds = NO;
  backView.layer.shadowColor = [UIColor blackColor].CGColor;
  backView.layer.shadowOpacity = 1;
  backView.layer.shadowOffset = CGSizeMake(-5, -5);
  backView.layer.shadowRadius = 20;
  backView.layer.shadowPath = path.CGPath;
  backView.layer.shouldRasterize = YES;
  [self.superview addSubview:backView];
  [self.superview bringSubviewToFront:self];
  return backView;
}

- (void)addShadowsCategory {

  self.layer.shadowColor = [UIColor blackColor].CGColor;
  self.layer.shadowOffset = CGSizeMake(2.0, 2.0);
  self.layer.shadowRadius = 3.0;
  self.layer.shadowOpacity = 0.6;
//    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.frame
//                                                    cornerRadius:5];
  self.layer.shouldRasterize = YES;
  self.layer.rasterizationScale = [UIScreen mainScreen].scale;

  //[self.layer setShadowPath:path.CGPath];

//    [self.layer setShadowPath:[UIBezierPath
//                               bezierPathWithRect:self.bounds].CGPath];


}


@end
