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

/*
 CGContextSetLineWidth(context, 2.0);
 
 CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
 
 CGFloat components[] = {0.0, 0.0, 1.0, 1.0};
 
 CGColorRef color = CGColorCreate(colorspace, components);
 
 CGContextSetStrokeColorWithColor(context, color);
 
 CGContextMoveToPoint(context, 0, 0);
 CGContextAddLineToPoint(context, 300, 400);
 
 CGContextStrokePath(context);
 CGColorSpaceRelease(colorspace);
 CGColorRelease(color);
 
 
 */



- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 1.0);
    
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    
    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMidY(rect));
    CGContextAddLineToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGContextClosePath(context);

    CGContextStrokePath(context);
    
    /*
    CGContextBeginPath(ctx);
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(ctx, 2.0);
    
    CGContextMoveToPoint(ctx, CGRectGetMinX(rect), CGRectGetMinY(rect));     // top left
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMidY(rect));  // mid right
    CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), CGRectGetMaxY(rect));  // bottom left
  //  CGContextClosePath(ctx);

    // CGContextSetRGBFillColor(ctx, 1, 1, 1, 1);

   // CGContextFillPath(ctx);*/
}

@end
