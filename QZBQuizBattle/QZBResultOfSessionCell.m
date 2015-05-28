//
//  QZBResultOfSessionCell.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 25/04/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBResultOfSessionCell.h"
#import "UIView+QZBShakeExtension.h"
@implementation QZBResultOfSessionCell

- (void)awakeFromNib {
    // Initialization code
    
    [self.backView addShadowsAllWay];
    [self.underView addShadowsAllWay];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
