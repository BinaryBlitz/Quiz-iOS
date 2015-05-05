//
//  QZBTopicTableViewCell.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 24/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import "QZBTopicTableViewCell.h"

@interface QZBTopicTableViewCell()

@property(strong, nonatomic) UILabel *centralLabel;
@property(strong, nonatomic) UIImageView *icon;
@property(assign, nonatomic) BOOL visible;

@end

@implementation QZBTopicTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.topicProgressView.lineWidth = 2;
    self.topicProgressView.fillOnTouch = NO;
    self.topicProgressView.tintColor = [UIColor blackColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)initCircularProgressWithLevel:(NSInteger)level
                            progress:(float)progress
                             visible:(BOOL)visible{
    self.visible = visible;
    
    if(!visible){
        self.topicProgressView.tintColor = [UIColor clearColor];
        self.topicProgressView.centralView = self.icon;
        self.icon.image = [UIImage imageNamed:@"lockIcon"];
        return;
    }


    if (progress > 0 || level > 0) {
        
        self.topicProgressView.centralView = self.centralLabel;
        self.topicProgressView.tintColor = [UIColor blackColor];
        self.centralLabel.text = [NSString stringWithFormat:@"%ld", (long)level];
        self.topicProgressView.progress = progress;

    } else {
        self.topicProgressView.tintColor = [UIColor clearColor];
        self.topicProgressView.centralView = self.icon;
        
        self.icon.image = [UIImage imageNamed:@"downIcon"];
    }
}



-(UILabel *)centralLabel{
    if(!_centralLabel){
       _centralLabel = [[UILabel alloc]
         initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.topicProgressView.frame) / 2.0,
                                  CGRectGetWidth(self.topicProgressView.frame) / 2.0)];
        
        _centralLabel.textColor = [UIColor blackColor];
        _centralLabel.textAlignment = NSTextAlignmentCenter;
        _centralLabel.adjustsFontSizeToFitWidth = YES;
        
        _centralLabel.font = [UIFont systemFontOfSize:12];
    }
    return _centralLabel;
}

-(UIImageView *)icon{
    if(!_icon){
        
        _icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    }
    return _icon;
}



@end
