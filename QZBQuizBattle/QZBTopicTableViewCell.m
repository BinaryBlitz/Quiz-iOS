//
//  QZBTopicTableViewCell.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 24/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import "QZBTopicTableViewCell.h"

@implementation QZBTopicTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.topicProgressView.lineWidth = 4;
    self.topicProgressView.fillOnTouch = NO;
    self.topicProgressView.tintColor = [UIColor blackColor];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
