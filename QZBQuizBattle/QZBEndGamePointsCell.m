//
//  QZBEndGamePointsCell.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 09/04/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBEndGamePointsCell.h"
#import "UIColor+QZBProjectColors.h"
#import "UITableViewCell+QZBCellCategory.h"
#import "NSString+QZBStringCategory.h"

@implementation QZBEndGamePointsCell

- (void)awakeFromNib {
    // Initialization code
    [self addDropShadows];
    self.circleView.borderWidth = 10;
    CGRect rect = CGRectMake(0, 0, CGRectGetHeight(self.circleView.frame) / 2.0,
                             CGRectGetHeight(self.circleView.frame) / 2.0);

    UILabel *centralLabel = [[UILabel alloc] initWithFrame:rect];
    centralLabel.font = [UIFont boldSystemFontOfSize:40];
    centralLabel.textAlignment = NSTextAlignmentCenter;
    self.circleView.centralView = centralLabel;
    self.circleView.fillOnTouch = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCentralLabelWithNimber:(NSInteger)multiplier {
    UIColor *color = [UIColor whiteColor];

    if (multiplier == 1) {
    } else if (multiplier == 2) {
        color = [UIColor lightButtonColor];

    } else if (multiplier == 3) {
        color = [UIColor lightGreenColor];

    } else if (multiplier == 5) {
        color = [UIColor lightRedColor];
    }

    self.circleView.tintColor = color;

    UILabel *label = (UILabel *)self.circleView.centralView;
    label.textColor = color;
    label.text = [NSString stringWithFormat:@"x%ld", (long)multiplier];
}

- (void)setScore:(NSUInteger)score {
    self.pointsLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)score];
    self.pointsNameLabel.text = [NSString endOfWordFromNumber:score]; 
}

//- (NSString *)endOfWordFromNumber:(NSInteger)number {
//    NSInteger num = number / 100;
//
//    if (num > 20) {
//        num = num / 10;
//    }
//    if (num == 0) {
//        return @"очков";
//    } else if (num >= 5 && num <= 20) {
//        return @"очков";
//    } else if (num == 1) {
//        return @"очко";
//    } else {
//        return @"очка";
//    }
//}

@end
