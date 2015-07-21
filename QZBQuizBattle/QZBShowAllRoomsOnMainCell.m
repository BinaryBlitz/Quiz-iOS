//
//  QZBRoomsOnMainCell.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 21/07/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBShowAllRoomsOnMainCell.h"
#import "UIView+QZBShakeExtension.h"

@implementation QZBShowAllRoomsOnMainCell


-(void)drawRect:(CGRect)rect {
    [self.backView addShadowsAllWay];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
