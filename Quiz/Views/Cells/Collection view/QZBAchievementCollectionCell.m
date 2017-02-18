#import "QZBAchievementCollectionCell.h"

@implementation QZBAchievementCollectionCell

- (void)awakeFromNib {
  self.achievementTitle.adjustsFontSizeToFitWidth = YES;
  self.achievementTitle.minimumScaleFactor = 0.5;
  self.achievementTitle.numberOfLines = 1;
  // self.achievementTitle.minimumScaleFactor = 1.5;
}

@end
