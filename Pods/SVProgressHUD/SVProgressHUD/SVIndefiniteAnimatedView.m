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



-(UIBezierPath *)destinationPathWithRect: (CGRect)frame
{
    //// Color Declarations
   // UIColor* color = [UIColor colorWithRed: 0.5 green: 0.5 blue: 0.5 alpha: 0.399];
    
    //// Bezier 3 Drawing
//    UIBezierPath* bezier3Path = UIBezierPath.bezierPath;
//    [bezier3Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.36963 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.19092 * CGRectGetHeight(frame))];
//    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.42432 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34912 * CGRectGetHeight(frame))];
//    [bezier3Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34229 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.55420 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.42432 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34912 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.29443 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41553 * CGRectGetHeight(frame))];
//    [bezier3Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.53076 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.66455 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.39014 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.69287 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.53076 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.66455 * CGRectGetHeight(frame))];
//    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.58740 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.82568 * CGRectGetHeight(frame))];
//    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.36963 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.90186 * CGRectGetHeight(frame))];
//    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.22217 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.47314 * CGRectGetHeight(frame))];
//    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.14209 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.50146 * CGRectGetHeight(frame))];
//    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.15088 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26514 * CGRectGetHeight(frame))];
//    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.36963 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.19092 * CGRectGetHeight(frame))];
//    [bezier3Path closePath];
//    [bezier3Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.63232 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.80908 * CGRectGetHeight(frame))];
//    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.57764 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65088 * CGRectGetHeight(frame))];
//    [bezier3Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.65967 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44580 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.57764 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65088 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.70752 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.58447 * CGRectGetHeight(frame))];
//    [bezier3Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.47119 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33545 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.61182 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.30713 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.47119 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33545 * CGRectGetHeight(frame))];
//    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.41455 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17432 * CGRectGetHeight(frame))];
//    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.63232 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09814 * CGRectGetHeight(frame))];
//    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.77979 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52686 * CGRectGetHeight(frame))];
//    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.85986 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.49854 * CGRectGetHeight(frame))];
//    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.85107 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73486 * CGRectGetHeight(frame))];
//    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.63232 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.80908 * CGRectGetHeight(frame))];
//    [bezier3Path closePath];
//   // [color setFill];
// //   [bezier3Path fill];
// //   [UIColor.blackColor setStroke];
//    bezier3Path.lineWidth = 3;
  //  [bezier3Path stroke];
    
    UIBezierPath* bezier4Path = UIBezierPath.bezierPath;
    [bezier4Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.36963 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.19092 * CGRectGetHeight(frame))];
    [bezier4Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.42432 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34912 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34229 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.55420 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.42432 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34912 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.29443 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.41553 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.53076 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.66455 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.39014 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.69287 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.53076 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.66455 * CGRectGetHeight(frame))];
    [bezier4Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.58740 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.82568 * CGRectGetHeight(frame))];
    [bezier4Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.36963 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.90186 * CGRectGetHeight(frame))];
    [bezier4Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.22217 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.47314 * CGRectGetHeight(frame))];
    [bezier4Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.14209 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.50146 * CGRectGetHeight(frame))];
    [bezier4Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.15088 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26514 * CGRectGetHeight(frame))];
    [bezier4Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.36963 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.19092 * CGRectGetHeight(frame))];
    [bezier4Path closePath];
    [bezier4Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.63232 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.80908 * CGRectGetHeight(frame))];
    [bezier4Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.57764 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65088 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.65967 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44580 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.57764 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65088 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.70752 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.58447 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.47119 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33545 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.61182 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.30713 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.47119 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33545 * CGRectGetHeight(frame))];
    [bezier4Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.41455 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17432 * CGRectGetHeight(frame))];
    [bezier4Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.63232 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09814 * CGRectGetHeight(frame))];
    [bezier4Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.77979 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52686 * CGRectGetHeight(frame))];
    [bezier4Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.85986 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.49854 * CGRectGetHeight(frame))];
    [bezier4Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.85107 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73486 * CGRectGetHeight(frame))];
    [bezier4Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.63232 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.80908 * CGRectGetHeight(frame))];
    [bezier4Path closePath];
    [bezier4Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.40771 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46436 * CGRectGetHeight(frame))];
    [bezier4Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.45264 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.55615 * CGRectGetHeight(frame))];
    [bezier4Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.46631 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.55615 * CGRectGetHeight(frame))];
    [bezier4Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.51221 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46436 * CGRectGetHeight(frame))];
    [bezier4Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.48486 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46436 * CGRectGetHeight(frame))];
    [bezier4Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.45947 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.51318 * CGRectGetHeight(frame))];
    [bezier4Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.43506 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46436 * CGRectGetHeight(frame))];
    [bezier4Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.40771 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46436 * CGRectGetHeight(frame))];
    [bezier4Path closePath];
    [bezier4Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.58203 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.47070 * CGRectGetHeight(frame))];
    [bezier4Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.57031 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.48535 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.55664 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.47949 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.57031 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.48535 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.56445 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.48047 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.54590 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.48926 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.54883 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.47852 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.54492 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.48145 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.57910 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.50586 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.54688 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.49707 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.56445 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.49414 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.57910 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.54785 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.59375 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.51758 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.58691 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.53906 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.54297 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.55859 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.57129 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.55664 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.56006 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.55908 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.51367 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.54395 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.52588 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.55811 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.51367 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.54395 * CGRectGetHeight(frame))];
    [bezier4Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.52832 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52734 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.54590 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.53809 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.52832 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52734 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.53784 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.53760 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.56055 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52734 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.55396 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.53857 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.56055 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.53711 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.52637 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.50586 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.56055 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.51758 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.53687 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.51587 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.54785 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46094 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.51587 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.49585 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.51660 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46191 * CGRectGetHeight(frame))];
    [bezier4Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.58203 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.47070 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.57910 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45996 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.58203 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.47070 * CGRectGetHeight(frame))];
    [bezier4Path closePath];
    bezier4Path.lineWidth = 3;
    
    return bezier4Path;
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
