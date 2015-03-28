//
//  QZBStatiscticCell.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 27/03/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBStatiscticCell.h"

@implementation QZBStatiscticCell

- (void)awakeFromNib {
    // Initialization code
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
