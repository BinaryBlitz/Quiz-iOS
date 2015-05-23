//
//  QZBLastElementInHorizontalTCCell.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 22/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBLastElementInHorizontalTCCell.h"
#import "QZBHorizontalCell.h"
#import "UIColor+QZBProjectColors.h"
#import "UIFont+QZBCustomFont.h"

@implementation QZBLastElementInHorizontalTCCell

- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.button.backgroundColor = [UIColor lightButtonColor];
        self.button.titleLabel.font = [UIFont museoFontOfSize:13];
        self.button.layer.cornerRadius = 10.0;
        self.button.clipsToBounds = YES;
        // [self.button setTitle:@"Показать \nвсех" forState:UIControlStateNormal];
        self.button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.button.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.button.transform = CGAffineTransformMakeRotation(1.5707963);
        [self.button setFrame:CGRectMake(40, 10, 80, 80)];
        [self addSubview:self.button];

        [self.button addTarget:self
                        action:@selector(showAll:)
              forControlEvents:UIControlEventTouchUpInside];

        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
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
    NSIndexPath *ip = [self getIndexPathCell:self];

    [[NSNotificationCenter defaultCenter]

        postNotificationName:@"QZBUserPressShowAllButton"
                      object:ip];
}

- (NSIndexPath *)getIndexPathCell:(UIView *)view {
    if ([view isKindOfClass:[QZBHorizontalCell class]]) {
        // UITableView *tv = (UITableView *)view.superview;

        NSIndexPath *indexPath =
            [(UITableView *)view.superview.superview indexPathForCell:(UITableViewCell *)view];
        return indexPath;

    } else {
        return [self getIndexPathCell:view.superview];
    }
}

- (void)setButtonTitle:(NSString *)buttonTitle {
    [self.button setTitle:buttonTitle forState:UIControlStateNormal];
}

@end
