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
  NSNumber *opponentUserScore = @(0);

  if(user.userStatistics.losses){
    opponentUserScore = user.userStatistics.losses;
  }

  NSNumber *currentUserScore = @(0);
  if (user.userStatistics.wins) {
    currentUserScore = user.userStatistics.wins;
  }

  self.currentUserScoreLabel.text = [NSString stringWithFormat:@"%@-%@",
                                     currentUserScore,opponentUserScore];
}

@end
