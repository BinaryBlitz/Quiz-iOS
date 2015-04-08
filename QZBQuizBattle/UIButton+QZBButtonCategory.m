//
//  UIButton+QZBButtonCategory.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 07/04/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "UIButton+QZBButtonCategory.h"

@implementation UIButton (QZBButtonCategory)

-(void)configButtonWithRoundedBorders{
    self.layer.borderWidth = 1.0;
    self.layer.borderColor =self.tintColor.CGColor;
    self.layer.cornerRadius = 5.0;
    self.clipsToBounds = YES;
    [self setTitle:@"" forState:UIControlStateNormal];
    self.enabled = NO;
}


@end
