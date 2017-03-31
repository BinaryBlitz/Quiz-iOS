#import "QZBAnswerTriangle.h"

@implementation QZBAnswerTriangle

- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();

  CGContextSetLineWidth(context, 1.0);

  CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);

  CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
  CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMidY(rect));
  CGContextAddLineToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect));
  CGContextClosePath(context);

  CGContextStrokePath(context);
}

@end
