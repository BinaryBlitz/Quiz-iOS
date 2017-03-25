#import "QZBEndGameMainCell.h"
#import <JSBadgeView.h>
#import "UIColor+QZBProjectColors.h"
#import "UIView+QZBShakeExtension.h"
#import "UIFont+QZBCustomFont.h"

@implementation QZBEndGameMainCell

- (void)awakeFromNib {
  [super awakeFromNib];

  // Initialization code
  self.firstUserScore.text = @"";
  self.opponentScore.text = @"";

  self.userBV = [[JSBadgeView alloc] initWithParentView:self.firstUserScore
                                              alignment:JSBadgeViewAlignmentCenterLeft];
  self.opponentBV = [[JSBadgeView alloc] initWithParentView:self.opponentScore
                                                  alignment:JSBadgeViewAlignmentCenterRight];

  self.userBV.badgeTextFont = [UIFont museoFontOfSize:20];
  self.opponentBV.badgeTextFont = [UIFont museoFontOfSize:20];
  self.userBV.badgeBackgroundColor = [UIColor transperentLightBlueColor];
  self.opponentBV.badgeBackgroundColor = [UIColor transperentLightBlueColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

//// Configure the view for the selected state
}

- (void)initCell {
  self.firstUserScore.text = @"";
  self.opponentScore.text = @"";

  self.userBV = [[JSBadgeView alloc] initWithParentView:self.firstUserScore
                                              alignment:JSBadgeViewAlignmentCenterLeft];
  self.opponentBV = [[JSBadgeView alloc] initWithParentView:self.opponentScore
                                                  alignment:JSBadgeViewAlignmentCenterRight];

  self.userBV.badgeTextFont = [UIFont museoFontOfSize:20];
  self.opponentBV.badgeTextFont = [UIFont museoFontOfSize:20];
  self.userBV.badgeBackgroundColor = [UIColor transperentLightBlueColor];
  self.opponentBV.badgeBackgroundColor = [UIColor transperentLightBlueColor];
}

@end
