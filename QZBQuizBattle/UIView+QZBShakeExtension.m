//
//  UIView+QZBShakeExtension.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 20/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "UIView+QZBShakeExtension.h"

@implementation UIView (QZBShakeExtension)

- (void)shakeView {
    [self shakeDirection:1 shakes:0];
}

- (void)shakeDirection:(int)direction shakes:(int)shakes {
    [UIView animateWithDuration:0.03
        animations:^{
            self.transform = CGAffineTransformMakeTranslation(5 * direction, 0);
        }
        completion:^(BOOL finished) {
            if (shakes >= 10) {
                self.transform = CGAffineTransformIdentity;
                return;
            }
            __block int shakess = shakes;
            shakess++;
            __block int directionn = direction;
            directionn = directionn * -1;
            [self shakeDirection:directionn shakes:shakess];
        }];
}

-(void)addDropShadowsForView{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                            -10,
                                                            CGRectGetWidth([UIScreen
                                                                            mainScreen].bounds),
                                                            10)];
    
    view.backgroundColor = [UIColor clearColor];
     self.clipsToBounds = YES;
    //self.layer.masksToBounds = YES;
    view.layer.masksToBounds = NO;
    view.layer.shadowOffset = CGSizeMake(0.0f, 4.0f);
    view.layer.shadowColor = [[UIColor blackColor] CGColor];
    view.layer.shadowRadius = 5;
    view.layer.shadowOpacity = .4;
    
    [view.layer setShadowPath:[UIBezierPath
                               bezierPathWithRect:view.bounds].CGPath];
    
    [self addSubview:view];
    
    
    
}

-(void)addShadows{
    self.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(2.0, 2.0);
    self.layer.shadowRadius = 2.0;
    self.layer.shadowOpacity = 0.5;
}


@end
