//
//  QZBVSScoreLabel.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 27/03/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBVSScoreCell.h"
#import "QZBAnotherUser.h"
#import "QZBUserStatistic.h"
#import "QZBCurrentUser.h"
#import "QZBUser.h"
#import "UITableViewCell+QZBCellCategory.h"

@implementation QZBVSScoreCell

- (void)awakeFromNib {
    // Initialization code
    [self addDropShadows];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setCellWithUser:(QZBAnotherUser *)user{
    
  //  QZBUserStatistic
    
    //self.anotherUserNameLabel.text = user.name;
    
    NSNumber *opponentUserScore = @(0);
    
    if(user.userStatistics.losses){
        opponentUserScore = user.userStatistics.losses;
    }
    
    //self.opponentUserScoreLabel.text = [NSString stringWithFormat:@"%@", opponentUserScore];
    //self.currentUserNameLabel.text = [QZBCurrentUser sharedInstance].user.name;
    
    NSNumber *currentUserScore = @(0);
    if(user.userStatistics.wins){
        currentUserScore = user.userStatistics.wins;
    }
    self.currentUserScoreLabel.text = [NSString stringWithFormat:@"%@-%@",
                                       currentUserScore,opponentUserScore];

    
}

@end
