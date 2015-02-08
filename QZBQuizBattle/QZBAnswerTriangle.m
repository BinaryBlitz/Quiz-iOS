//
//  QZBAnswerTriangle.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 21/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import "QZBAnswerTriangle.h"

@implementation QZBAnswerTriangle

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, CGRectGetMinX(rect), CGRectGetMinY(rect));     // top left
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMidY(rect));  // mid right
    CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), CGRectGetMaxY(rect));  // bottom left
    CGContextClosePath(ctx);

    // CGContextSetRGBFillColor(ctx, 1, 1, 1, 1);

    CGContextFillPath(ctx);
}

@end
