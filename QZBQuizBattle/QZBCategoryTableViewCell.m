//
//  QZBCategoryTableViewCell.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 15/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBCategoryTableViewCell.h"
#import "UIView+QZBShakeExtension.h"

@implementation QZBCategoryTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    [self.backView addShadowsCategory];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
