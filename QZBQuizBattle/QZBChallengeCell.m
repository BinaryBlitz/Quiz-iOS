//
//  QZBChallengeCell.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 18/03/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBChallengeCell.h"
#import "UIView+QZBShakeExtension.h"

@implementation QZBChallengeCell

-(void)awakeFromNib{
    [self.backView addShadowsAllWay];
    [self.underView addShadowsAllWay];
}

@end
