//
//  QZBAnswerCircle.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 08/03/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBAnswerCircle.h"

@implementation QZBAnswerCircle


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
   // CGRect borderRect = CGRectMake(0.0, 0.0, 60.0, 60.0);
    CGRect borderRect = CGRectInset(rect, 2, 2);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
    CGContextSetRGBFillColor(context, 1.0 , 1.0, 1.0, 1.0);
    CGContextSetLineWidth(context, 1.0);
    CGContextFillEllipseInRect (context, borderRect);
    CGContextStrokeEllipseInRect(context, borderRect);
    
    CGContextFillPath(context);
}

    



@end
