#import "UITableViewCell+QZBCellCategory.h"

@implementation UITableViewCell (QZBCellCategory)

- (UIView *)addDropShadows {

//    CALayer *bottomBorder = [CALayer layer];
//    bottomBorder.frame    = CGRectMake(0.0f,
//                                       (CGRectGetHeight(self.contentView.bounds) - 1),
//                                       CGRectGetWidth(self.contentView.bounds),
//                                       1.0f);
//    
//    bottomBorder.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f].CGColor;
//    [self.contentView.layer addSublayer:bottomBorder];


//    self.layer.masksToBounds = NO;
//    self.layer.shadowOffset = CGSizeMake(0.0f, 10.0f);
//    self.layer.shadowColor = [[UIColor blackColor] CGColor];
//    self.layer.shadowRadius = 5;
//    self.layer.shadowOpacity = .25;
//   // self.clipsToBounds = NO;
//   
//   // [self layoutSubviews];
//    
//    
////    CGRect shadowFrame = self.bounds;
////    CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:shadowFrame].CGPath;
////    self.layer.shadowPath = shadowPath;
//    
//    self.layer.shouldRasterize = YES;
//    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
//    
//    [self.layer setShadowPath:[UIBezierPath
//                                           bezierPathWithRect:self.bounds].CGPath];

  //[self setNeedsDisplay];

  UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,
      -10,
      CGRectGetWidth([UIScreen
          mainScreen].bounds),
      10)];

  view.backgroundColor = [UIColor clearColor];
  // self.clipsToBounds = YES;
  //self.layer.masksToBounds = YES;
  view.layer.masksToBounds = NO;
  view.layer.shadowOffset = CGSizeMake(0.0f, 4.0f);
  view.layer.shadowColor = [[UIColor blackColor] CGColor];
  view.layer.shadowRadius = 5;
  view.layer.shadowOpacity = .4;


//    view.layer.shouldRasterize = YES;
//    view.layer.rasterizationScale = [UIScreen mainScreen].scale;

  [view.layer setShadowPath:[UIBezierPath
      bezierPathWithRect:view.bounds].CGPath];

  [self addSubview:view];

  return view;
}

@end
