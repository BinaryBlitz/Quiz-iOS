#import "QZBStoreBoosterCell.h"

@implementation QZBStoreBoosterCell

- (void)awakeFromNib {
  [super awakeFromNib];

  self.layer.cornerRadius = 5.0;
  self.clipsToBounds = YES;
}

@end
