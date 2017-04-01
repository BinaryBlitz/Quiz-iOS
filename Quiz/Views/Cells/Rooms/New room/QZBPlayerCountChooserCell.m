#import "QZBPlayerCountChooserCell.h"


@implementation QZBPlayerCountChooserCell

- (void)awakeFromNib {
  [super awakeFromNib];

  NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:25]};
  [self.playersCountSegmentControll setTitleTextAttributes:attributes
                                                  forState:UIControlStateNormal];
  [self.playersCountSegmentControll setTitleTextAttributes:attributes forState:UIControlStateSelected];
}

@end
