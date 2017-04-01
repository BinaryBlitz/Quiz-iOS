#import "QZBEndGamePointsCell.h"
#import "UIColor+QZBProjectColors.h"
#import "NSString+QZBStringCategory.h"


@implementation QZBEndGamePointsCell

- (void)awakeFromNib {
  [super awakeFromNib];

  // Initialization code
  self.circleView.borderWidth = 10;
  CGRect rect = CGRectMake(0, 0, CGRectGetHeight(self.circleView.frame) / 2.0,
      CGRectGetHeight(self.circleView.frame) / 2.0);

  UILabel *centralLabel = [[UILabel alloc] initWithFrame:rect];
  centralLabel.font = [UIFont boldSystemFontOfSize:40];
  centralLabel.textAlignment = NSTextAlignmentCenter;
  self.circleView.centralView = centralLabel;
  self.circleView.fillOnTouch = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
}

- (void)setCentralLabelWithNimber:(NSInteger)multiplier {
  UIColor *color = [UIColor whiteColor];

  if (multiplier == 1) {
  } else if (multiplier == 2) {
    color = [UIColor lightButtonColor];
  } else if (multiplier == 3) {
    color = [UIColor lightGreenColor];
  } else if (multiplier == 5) {
    color = [UIColor lightRedColor];
  }

  self.circleView.tintColor = color;

  UILabel *label = (UILabel *) self.circleView.centralView;
  label.textColor = color;
  label.text = [NSString stringWithFormat:@"x%ld", (long) multiplier];
}

- (void)setScore:(NSUInteger)score {
  self.pointsLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long) score];
  self.pointsNameLabel.text = [NSString endOfWordFromNumber:score];
}

@end
