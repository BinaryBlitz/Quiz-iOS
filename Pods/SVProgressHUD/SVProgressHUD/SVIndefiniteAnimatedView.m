//
//  SVIndefiniteAnimatedView.m
//  SVProgressHUD
//
//  Created by Guillaume Campagna on 2014-12-05.
//
//

#import "SVIndefiniteAnimatedView.h"

#pragma mark SVIndefiniteAnimatedView

@interface SVIndefiniteAnimatedView ()

@property (nonatomic, strong) CAShapeLayer *indefiniteAnimatedLayer;

@end

@implementation SVIndefiniteAnimatedView

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview) {
        [self layoutAnimatedLayer];
    } else {
        [_indefiniteAnimatedLayer removeFromSuperlayer];
        _indefiniteAnimatedLayer = nil;
    }
}

- (void)layoutAnimatedLayer {
    CALayer *layer = self.indefiniteAnimatedLayer;
    
    [self.layer addSublayer:layer];
    layer.position = CGPointMake(CGRectGetWidth(self.bounds) - CGRectGetWidth(layer.bounds) / 2, CGRectGetHeight(self.bounds) - CGRectGetHeight(layer.bounds) / 2);
}

- (CAShapeLayer*)indefiniteAnimatedLayer {
    if(!_indefiniteAnimatedLayer) {
        CGPoint arcCenter = CGPointMake(self.radius+self.strokeThickness/2+5, self.radius+self.strokeThickness/2+5);
        CGRect rect = CGRectMake(0.0f, 0.0f, arcCenter.x*2, arcCenter.y*2);
        
//        UIBezierPath* smoothedPath = [UIBezierPath bezierPathWithArcCenter:arcCenter
//                                                                    radius:self.radius
//                                                                startAngle:M_PI*3/2
//                                                                  endAngle:M_PI/2+M_PI*5
//                                                                 clockwise:YES];
        UIBezierPath* smoothedPath = [self destinationPathWithRect:rect];
        
        
        _indefiniteAnimatedLayer = [CAShapeLayer layer];
        _indefiniteAnimatedLayer.contentsScale = [[UIScreen mainScreen] scale];
        _indefiniteAnimatedLayer.frame = rect;
        _indefiniteAnimatedLayer.fillColor = [UIColor clearColor].CGColor;
        _indefiniteAnimatedLayer.strokeColor = self.strokeColor.CGColor;
        _indefiniteAnimatedLayer.lineWidth = self.strokeThickness;
        _indefiniteAnimatedLayer.lineCap = kCALineCapRound;
        _indefiniteAnimatedLayer.lineJoin = kCALineJoinBevel;
        _indefiniteAnimatedLayer.path = smoothedPath.CGPath;
        
      //  _indefiniteAnimatedLayer
        
//        CALayer *maskLayer = [CALayer layer];
//        maskLayer.contents = (id)[[UIImage imageNamed:@"SVProgressHUD.bundle/angle-mask"] CGImage];
//        maskLayer.frame = _indefiniteAnimatedLayer.bounds;
//        _indefiniteAnimatedLayer.mask = maskLayer;
        
        NSTimeInterval animationDuration = 1;
        CAMediaTimingFunction *linearCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        animation.fromValue = 0;
        animation.toValue = [NSNumber numberWithFloat:M_PI*2];
        animation.duration = animationDuration;
        animation.timingFunction = linearCurve;
        animation.removedOnCompletion = NO;
        animation.repeatCount = INFINITY;
        animation.fillMode = kCAFillModeForwards;
        animation.autoreverses = NO;
        
       // [_indefiniteAnimatedLayer addAnimation:animation forKey:@"rotate"];
        
//        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
//        animationGroup.duration = animationDuration;
//        animationGroup.repeatCount = INFINITY;
//        animationGroup.removedOnCompletion = NO;
//        animationGroup.timingFunction = linearCurve;
//        
//        CABasicAnimation *strokeStartAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
//        strokeStartAnimation.fromValue = @0.015;
//        strokeStartAnimation.toValue = @0.515;
//        
//        CABasicAnimation *strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
//        strokeEndAnimation.fromValue = @0.485;
//        strokeEndAnimation.toValue = @0.985;
//        
//        animationGroup.animations = @[strokeStartAnimation, strokeEndAnimation];
        [_indefiniteAnimatedLayer addAnimation:animation forKey:@"progress"];
        
    }
    return _indefiniteAnimatedLayer;
}

//-(UIBezierPath *)destinationPathWithRect:(CGRect)rect {
//  //  UIColor* color = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
//    
//    //// Group
//    
//        //// Bezier 4 Drawing
////        UIBezierPath* bezier4Path = UIBezierPath.bezierPath;
////        [bezier4Path moveToPoint: CGPointMake(20.7, 8.05)];
////        [bezier4Path addLineToPoint: CGPointMake(25.17, 20.03)];
////        [bezier4Path addCurveToPoint: CGPointMake(18.7, 35.46) controlPoint1: CGPointMake(25.17, 20.03) controlPoint2: CGPointMake(14.85, 25.56)];
////        [bezier4Path addCurveToPoint: CGPointMake(33.64, 43.61) controlPoint1: CGPointMake(22.55, 45.36) controlPoint2: CGPointMake(33.64, 43.61)];
////        [bezier4Path addLineToPoint: CGPointMake(37.95, 55.4)];
////        [bezier4Path addLineToPoint: CGPointMake(20.74, 61)];
////        [bezier4Path addLineToPoint: CGPointMake(9.22, 29.35)];
////        [bezier4Path addLineToPoint: CGPointMake(3, 31.24)];
////        [bezier4Path addLineToPoint: CGPointMake(3.5, 13.65)];
////        [bezier4Path addLineToPoint: CGPointMake(20.7, 8.05)];
////        [bezier4Path addLineToPoint: CGPointMake(20.7, 8.05)];
////        [bezier4Path closePath];
////        [bezier4Path moveToPoint: CGPointMake(41.83, 1)];
////        [bezier4Path addLineToPoint: CGPointMake(53.31, 33.1)];
////        [bezier4Path addLineToPoint: CGPointMake(59.5, 31.24)];
////        [bezier4Path addLineToPoint: CGPointMake(58.88, 48.7)];
////        [bezier4Path addLineToPoint: CGPointMake(41.33, 54.23)];
////        [bezier4Path addLineToPoint: CGPointMake(37.15, 42.41)];
////        [bezier4Path addCurveToPoint: CGPointMake(43.8, 27.45) controlPoint1: CGPointMake(37.15, 42.41) controlPoint2: CGPointMake(47.03, 37.35)];
////        [bezier4Path addCurveToPoint: CGPointMake(28.71, 18.86) controlPoint1: CGPointMake(40.56, 17.55) controlPoint2: CGPointMake(28.71, 18.86)];
////        [bezier4Path addLineToPoint: CGPointMake(24.16, 6.75)];
////        [bezier4Path addLineToPoint: CGPointMake(41.83, 1)];
////        [bezier4Path addLineToPoint: CGPointMake(41.83, 1)];
////        [bezier4Path closePath];
////        bezier4Path.lineCapStyle = kCGLineCapRound;
////        
////        bezier4Path.lineJoinStyle = kCGLineJoinBevel;
////        
////        [color setFill];
////        [bezier4Path fill];
////        [UIColor.blackColor setStroke];
////        bezier4Path.lineWidth = 1;
////        [bezier4Path stroke];
//    UIBezierPath* bezier4Path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(32, 32)
//                                                                                                      radius:self.radius
//                                                                                                  startAngle:M_PI*3/2
//                                                                                                    endAngle:M_PI/2+M_PI*5
//                                                                                                   clockwise:YES];
//    
//    return bezier4Path;
//}

-(UIBezierPath *)destinationPathWithRect: (CGRect)frame
{
    //// Color Declarations
   // UIColor* color = [UIColor colorWithRed: 0.5 green: 0.5 blue: 0.5 alpha: 0.399];
    
    //// Bezier 3 Drawing
    UIBezierPath* bezier3Path = UIBezierPath.bezierPath;
    [bezier3Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.36963 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.19092 * CGRectGetHeight(frame))];
    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.42432 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34912 * CGRectGetHeight(frame))];
    [bezier3Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34229 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.55420 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.42432 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34912 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.29443 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41553 * CGRectGetHeight(frame))];
    [bezier3Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.53076 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.66455 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.39014 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.69287 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.53076 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.66455 * CGRectGetHeight(frame))];
    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.58740 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.82568 * CGRectGetHeight(frame))];
    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.36963 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.90186 * CGRectGetHeight(frame))];
    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.22217 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.47314 * CGRectGetHeight(frame))];
    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.14209 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.50146 * CGRectGetHeight(frame))];
    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.15088 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26514 * CGRectGetHeight(frame))];
    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.36963 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.19092 * CGRectGetHeight(frame))];
    [bezier3Path closePath];
    [bezier3Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.63232 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.80908 * CGRectGetHeight(frame))];
    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.57764 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65088 * CGRectGetHeight(frame))];
    [bezier3Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.65967 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44580 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.57764 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65088 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.70752 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.58447 * CGRectGetHeight(frame))];
    [bezier3Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.47119 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33545 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.61182 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.30713 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.47119 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33545 * CGRectGetHeight(frame))];
    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.41455 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17432 * CGRectGetHeight(frame))];
    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.63232 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09814 * CGRectGetHeight(frame))];
    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.77979 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52686 * CGRectGetHeight(frame))];
    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.85986 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.49854 * CGRectGetHeight(frame))];
    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.85107 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73486 * CGRectGetHeight(frame))];
    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.63232 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.80908 * CGRectGetHeight(frame))];
    [bezier3Path closePath];
   // [color setFill];
 //   [bezier3Path fill];
 //   [UIColor.blackColor setStroke];
    bezier3Path.lineWidth = 3;
  //  [bezier3Path stroke];
    
    return bezier3Path;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    if (self.superview) {
        [self layoutAnimatedLayer];
    }
}

- (void)setRadius:(CGFloat)radius {
    _radius = radius;
    
    [_indefiniteAnimatedLayer removeFromSuperlayer];
    _indefiniteAnimatedLayer = nil;
    
    if (self.superview) {
        [self layoutAnimatedLayer];
    }
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    _strokeColor = strokeColor;
    _indefiniteAnimatedLayer.strokeColor = strokeColor.CGColor;
}

- (void)setStrokeThickness:(CGFloat)strokeThickness {
    _strokeThickness = strokeThickness;
    _indefiniteAnimatedLayer.lineWidth = _strokeThickness;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake((self.radius+self.strokeThickness/2+5)*2, (self.radius+self.strokeThickness/2+5)*2);
}

@end
