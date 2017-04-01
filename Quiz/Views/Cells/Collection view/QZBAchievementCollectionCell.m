#import "QZBAchievementCollectionCell.h"

@implementation QZBAchievementCollectionCell

- (void)awakeFromNib {
  [super awakeFromNib];

  self.achievementTitle.adjustsFontSizeToFitWidth = YES;
  self.achievementTitle.minimumScaleFactor = 0.5;
  self.achievementTitle.numberOfLines = 1;
}

@end
