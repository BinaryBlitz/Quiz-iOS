//
//  QZBTopicBackView.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 02/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBTopicBackView.h"

@implementation QZBTopicBackView




- (UIViewContentMode)contentMode {
    return UIViewContentModeRedraw;
}

- (void)setFillColor:(UIColor *)fillColor {
    _fillColor = fillColor;
    [self setNeedsDisplay];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    [self setNeedsDisplay];
}

- (void)setShadowBlur:(CGFloat)shadowBlur {
    _shadowBlur = shadowBlur;
    [self setNeedsDisplay];
}

- (void)setShadowColor:(UIColor *)shadowColor {
    _shadowColor = shadowColor;
    [self setNeedsDisplay];
}

- (void)setShadowOffset:(CGSize)shadowOffset {
    _shadowOffset = shadowOffset;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [self fillIfNeeded];
    [self drawShadowIfNeeded];
}

- (void)fillIfNeeded {
    UIColor *color = self.fillColor;
    if (!color)
        return;
    
    [color setFill];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                    cornerRadius:self.cornerRadius];
    [path fill];
}


- (void)drawShadowIfNeeded {
    UIColor *color = self.shadowColor;
    if (!color)
        return;
    
    CGContextRef gc = UIGraphicsGetCurrentContext();
    CGContextSaveGState(gc); {
        [[UIBezierPath bezierPathWithRoundedRect:self.bounds
                                    cornerRadius:self.cornerRadius] addClip];
        
        UIBezierPath *invertedPath = [UIBezierPath bezierPathWithRect:CGRectInfinite];
        [invertedPath appendPath:[UIBezierPath bezierPathWithRoundedRect:
                                  CGRectInset(self.bounds, -1, -1) cornerRadius:self.cornerRadius]];
        invertedPath.usesEvenOddFillRule = YES;
        
        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(),
                                    self.shadowOffset, self.shadowBlur, color.CGColor);
        [[UIColor blackColor] setFill];
        [invertedPath fill];
        
    } CGContextRestoreGState(gc);
}

@end
