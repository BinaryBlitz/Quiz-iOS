#import "QZBVSScoreCell.h"
#import "QZBAnotherUser.h"

@implementation QZBVSScoreCell

- (void)setCellWithUser:(QZBAnotherUser *)user {
  NSNumber *opponentUserScore = @(0);

  if (user.userStatistics.losses) {
    opponentUserScore = user.userStatistics.losses;
  }

  NSNumber *currentUserScore = @(0);
  if (user.userStatistics.wins) {
    currentUserScore = user.userStatistics.wins;
  }

  self.currentUserScoreLabel.text = [NSString stringWithFormat:@"%@-%@",
                                                               currentUserScore, opponentUserScore];
}

@end
