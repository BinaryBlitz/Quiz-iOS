#import "QZBMainBoosterCell.h"
#import "UIButton+QZBButtonCategory.h"

@implementation QZBMainBoosterCell

- (void)awakeFromNib {
  [super awakeFromNib];

  [self.doubleBoosterButton configButtonWithRoundedBorders];
  [self.tripleBoosterButton configButtonWithRoundedBorders];
  [self.fiveTimesBoosterButton configButtonWithRoundedBorders];
}

- (void)configButton:(UIButton *)button {
  button.layer.borderWidth = 1.0;
  button.layer.borderColor = self.tintColor.CGColor;
  button.layer.cornerRadius = 5.0;
  button.clipsToBounds = YES;
  [button setTitle:@"" forState:UIControlStateNormal];
  button.enabled = NO;
}

- (void)configButtonNotPurchased:(UIButton *)button {
  [button setTitle:@"Купить" forState:UIControlStateNormal];
  button.enabled = YES;
  [button setTitleColor:self.tintColor forState:UIControlStateNormal];
}

- (void)configButtonPurchased:(UIButton *)button {
  [button setTitle:@"Куплено" forState:UIControlStateNormal];
  [button setTitle:@"Куплено" forState:UIControlStateDisabled];
  button.enabled = NO;
  [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
}

@end
