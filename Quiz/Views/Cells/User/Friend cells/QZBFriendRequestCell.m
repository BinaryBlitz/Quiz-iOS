#import "QZBFriendRequestCell.h"
#import "UIButton+QZBButtonCategory.h"

@implementation QZBFriendRequestCell

- (void)awakeFromNib {

  [self.acceptButton
      configButtonWithRoundedBorders];

  [self.acceptButton setTitle:@"Принять"
                     forState:UIControlStateNormal];
  self.acceptButton.enabled = YES;

  [self.declineButton configButtonFillAndRoundedCorners];

  [self.declineButton setExclusiveTouch:YES];
  [self.acceptButton setExclusiveTouch:YES];

}

@end
