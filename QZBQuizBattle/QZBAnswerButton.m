//
//  QZBAnswerButton.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 21/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import "QZBAnswerButton.h"
#import "QZBAnswerTriangle.h"

@implementation QZBAnswerButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)addTriangleLeft {
    CGRect rect =
        CGRectMake(0,
                   3.0 * self.frame.size.height / 12.0,
                   self.frame.size.height / 12.0,
                   self.frame.size.height / 2.0);

    QZBAnswerTriangle *triangle = [[QZBAnswerTriangle alloc] initWithFrame:rect];
    //[triangle setNeedsDisplay];
    triangle.backgroundColor = [UIColor clearColor];
    //triangle.tintColor = [UIColor redColor];

    [self addSubview:triangle];
}

- (void)addTriangleRight {
    

    CGRect rect = CGRectMake(11.0 * self.frame.size.width / 12.0,
                             3.0 * self.frame.size.height / 12.0,
                             self.frame.size.height / 12.0,
                             self.frame.size.height / 2.0);

    QZBAnswerTriangle *triangle = [[QZBAnswerTriangle alloc] initWithFrame:rect];
    
    triangle.transform = CGAffineTransformMakeRotation(M_PI);

    triangle.backgroundColor = [UIColor clearColor];
   // triangle.tintColor = [UIColor redColor];

    [self addSubview:triangle];
}

- (void)unshowTriangles {
    NSArray *subviews = self.subviews;

    for (UIView *view in subviews) {
        if ([view isKindOfClass:[QZBAnswerTriangle class]]) {
            [view removeFromSuperview];
        }
    }
}

@end
