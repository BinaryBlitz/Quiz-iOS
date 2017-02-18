#import "QZBFirstMessageCell.h"
#import "QZBAnotherUserWithLastMessages.h"
#import <JSBadgeView/JSBadgeView.h>
#import <UIImageView+AFNetworking.h>

@interface QZBFirstMessageCell ()

@property (strong, nonatomic) JSBadgeView *badgeView;

@end

@implementation QZBFirstMessageCell

- (void)awakeFromNib {
  self.badgeView = [[JSBadgeView alloc] initWithParentView:self.firstMessageLabel
                                                 alignment:JSBadgeViewAlignmentCenterRight];

}

- (void)setCellWithUserWithLastMessage:(QZBAnotherUserWithLastMessages *)userAndMessage {
  [super setCellWithUser:userAndMessage.user];

  self.firstMessageLabel.text = userAndMessage.lastMessage;

  self.timeLabel.text = userAndMessage.sinceNow;

  if (![userAndMessage.unreadedCount isEqualToNumber:@(0)]) {
    self.badgeView.badgeText = [userAndMessage.unreadedCount stringValue];
  } else {
    self.badgeView.badgeText = nil;
  }

  //   NSLog(@"%@", userAndMessage.unreadedCount);

  if (userAndMessage.user.imageURL) {
    [self.userpicImageView setImageWithURL:userAndMessage.user.imageURL
                          placeholderImage:[UIImage imageNamed:@"userpicStandart"]];
  } else {
    [self.userpicImageView setImage:[UIImage imageNamed:@"userpicStandart"]];
  }

}

@end
