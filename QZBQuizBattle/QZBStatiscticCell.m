//
//  QZBStatiscticCell.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 27/03/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBStatiscticCell.h"
#import <UAProgressView.h>
#import "UIColor+QZBProjectColors.h"

@implementation QZBStatiscticCell

- (void)awakeFromNib {
    
    static float boarderWidth = 6.0;
    // Initialization code
    self.winCircular.fillOnTouch = NO;
    self.drawsCircular.fillOnTouch = NO;
    self.lossesCircular.fillOnTouch = NO;
    
    self.winCircular.backgroundColor = [UIColor clearColor];
    self.drawsCircular.backgroundColor = [UIColor clearColor];
    self.lossesCircular.backgroundColor = [UIColor clearColor];
    
    self.winCircular.borderWidth = boarderWidth;
    self.drawsCircular.borderWidth = boarderWidth;
    self.lossesCircular.borderWidth = boarderWidth;
    
    self.winCircular.tintColor = [UIColor strongGreenColor];
    self.drawsCircular.tintColor = [UIColor orangeColor];
    self.lossesCircular.tintColor = [UIColor brightRedColor];
    
    
    
    
    self.winCircular.centralView = self.winLabel;
    self.drawsCircular.centralView = self.drawsLabel;
    self.lossesCircular.centralView = self.lossesLabel;
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellWithUser:(id <QZBUserProtocol>)user{
    
    QZBUserStatistic *statistic = user.userStatistics;
    
    NSNumber *wins = @(0);
    NSNumber *losses = @(0);
    NSNumber *draws = @(0);
    
    if(statistic.totalWins){
        wins = statistic.totalWins;
    }
    
    if(statistic.totaLosses){
        losses = statistic.totaLosses;
    }
    if(statistic.totalDraws){
        draws = statistic.totalDraws;
    }
    
    self.winLabel.text = [NSString stringWithFormat:@"%@",wins];
    self.lossesLabel.text = [NSString stringWithFormat:@"%@",losses];
    self.drawsLabel.text = [NSString stringWithFormat:@"%@", draws];
    
}



@end
