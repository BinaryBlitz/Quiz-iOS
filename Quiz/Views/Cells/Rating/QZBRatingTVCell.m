#import "QZBRatingTVCell.h"
#import "QZBUserInRating.h"
#import "QZBUser.h"
#import "QZBCurrentUser.h"


@interface QZBRatingTVCell ()

@property (strong, nonatomic) QZBUserInRating *user;

@end

@implementation QZBRatingTVCell

- (void)setCellWithUser:(QZBUserInRating *)user {

  self.user = user;

  if ([user.userID isEqual:[QZBCurrentUser sharedInstance].user.userID]) {
    NSMutableAttributedString *atrName = [[NSMutableAttributedString alloc] initWithString:user.name];

    UIFont *font = [UIFont boldSystemFontOfSize:18];
    [atrName addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [atrName length])];
    self.name.attributedText = atrName;
  } else {
    self.name.text = user.name;
  }

  self.numberInRating.text = [NSString stringWithFormat:@"%ld", (long) user.position];

  NSString *points = [NSString stringWithFormat:@"%ld", (long) user.points];
  if (user.points > 100000) {
    NSInteger newPoints = user.points / 1000;
    points = [NSString stringWithFormat:@"%ldк", (long) newPoints];
  }
  self.score.text = points;
}

@end
