//
//  QZBTopicTableViewCell.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 24/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import "QZBTopicTableViewCell.h"
#import "UIColor+QZBProjectColors.h"

@interface QZBTopicTableViewCell()

@property(strong, nonatomic) UILabel *centralLabel;
@property(strong, nonatomic) UIImageView *icon;
@property(assign, nonatomic) BOOL visible;

@end

@implementation QZBTopicTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.topicProgressView.lineWidth = 4;
    self.topicProgressView.fillOnTouch = NO;
    self.topicProgressView.tintColor = [UIColor ultralightGreenColor];
    
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
        self.topicProgressView.tintColor = [UIColor lightGreenColor];
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
         initWithFrame:CGRectMake(0,
                                  0,
                                  CGRectGetWidth(self.topicProgressView.frame) / 2.0,
                                  CGRectGetWidth(self.topicProgressView.frame) / 2.0)];
        
        _centralLabel.textColor = [UIColor lightGrayColor];
        _centralLabel.textAlignment = NSTextAlignmentCenter;
        _centralLabel.adjustsFontSizeToFitWidth = YES;
        
        _centralLabel.font = [UIFont systemFontOfSize:15];
    }
    return _centralLabel;
}

-(UIImageView *)icon{
    if(!_icon){
        
        _icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    }
    return _icon;
}



@end
