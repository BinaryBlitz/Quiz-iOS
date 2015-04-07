//
//  QZBMainBoosterCell.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 14/03/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBMainBoosterCell.h"

@implementation QZBMainBoosterCell

- (void)awakeFromNib {
    // Initialization code
    
    self.doubleBoosterButton.layer.borderWidth = 2.0;
    self.doubleBoosterButton.layer.borderColor = (__bridge CGColorRef)(self.tintColor);
    self.doubleBoosterButton.layer.cornerRadius = 5.0;
    self.doubleBoosterButton.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
