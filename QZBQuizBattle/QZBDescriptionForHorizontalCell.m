//
//  QZBDescriptionForHorizontalCell.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 06/04/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBDescriptionForHorizontalCell.h"
#import "UITableViewCell+QZBCellCategory.h"
@implementation QZBDescriptionForHorizontalCell

- (void)awakeFromNib {
    // Initialization code
    
    [self addDropShadows];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
