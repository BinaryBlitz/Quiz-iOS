//
//  QZBLastElementInHorizontalTCCell.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 22/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBLastElementInHorizontalTCCell.h"
#import "QZBHorizontalCell.h"

@implementation QZBLastElementInHorizontalTCCell

- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.button = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.button setTitle:@"Показать \nвсех" forState:UIControlStateNormal];
        self.button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.button.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.button.transform = CGAffineTransformMakeRotation(1.5707963);
        [self.button setFrame:CGRectMake(40, 0, 40, 100)];
        [self addSubview:self.button];

        [self.button addTarget:self action:@selector(showAll:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSString *)reuseIdentifier {
    return @"lastHorizontalElement";
}

- (void)showAll:(UIButton *)sender {
    if ([sender.superview isKindOfClass:[UITableViewCell class]]) {
        //  UITableViewCell *cell = (UITableViewCell *)sender.superview;
        // NSLog(@"%ld",[self getIndexPathCell:self].row);
        NSIndexPath *ip = [self getIndexPathCell:self];

        [[NSNotificationCenter defaultCenter]

            postNotificationName:@"QZBUserPressShowAllButton"
                          object:ip];
    }
}

- (NSIndexPath *)getIndexPathCell:(UIView *)view {
    if ([view isKindOfClass:[QZBHorizontalCell class]]) {
        // UITableView *tv = (UITableView *)view.superview;

        NSIndexPath *indexPath = [(UITableView *)view.superview.superview indexPathForCell:(UITableViewCell *)view];
        return indexPath;

    } else {
        return [self getIndexPathCell:view.superview];
    }
}

@end
