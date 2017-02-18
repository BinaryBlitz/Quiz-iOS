#import "QZBRoomUserResultCell.h"
#import "QZBUserWithTopic.h"
#import <UIImageView+AFNetworking.h>

@implementation QZBRoomUserResultCell

- (void)confirureWithUserWithTopic:(QZBUserWithTopic *)userWithTopic position:(NSNumber *)position {
  self.usernameLabel.text = [NSString stringWithFormat:@"%@. %@", position, userWithTopic.user.name];

  if (userWithTopic.finished) {
    self.userPointsLabel.text = [NSString stringWithFormat:@"%@", userWithTopic.points];
    self.waitingLabel.text = @"";
  } else {
    self.userPointsLabel.text = @"";
    self.waitingLabel.text = @"Ожидание";
  }

  if (userWithTopic.user.imageURL) {
    [self.userpicImageView setImageWithURL:userWithTopic.user.imageURL];
  } else {
    [self.userpicImageView setImage:[UIImage imageNamed:@"userpicStandart"]];
  }
}

@end
