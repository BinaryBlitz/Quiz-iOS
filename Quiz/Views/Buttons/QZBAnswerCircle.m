#import "QZBAnswerCircle.h"

@implementation QZBAnswerCircle

- (void)drawRect:(CGRect)rect {
  // Drawing code

  CGRect borderRect = CGRectInset(rect, 2, 2);
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
  CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
  CGContextSetLineWidth(context, 1.0);
  CGContextFillEllipseInRect(context, borderRect);
  CGContextStrokeEllipseInRect(context, borderRect);

  CGContextFillPath(context);
}


@end
