#import "QZBResultOfSessionCell.h"
#import "UIView+QZBShakeExtension.h"

@implementation QZBResultOfSessionCell

- (void)drawRect:(CGRect)rect {
  [self.backView addShadowsAllWay];
  [self.underView addShadowsAllWayRasterize];
}

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

  // Configure the view for the selected state
}

@end
