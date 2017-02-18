#import "UIButton+QZBButtonCategory.h"
#import "UIColor+QZBProjectColors.h"

@implementation UIButton (QZBButtonCategory)

- (void)configButtonWithRoundedBorders {
  self.layer.borderWidth = 1.0;
  self.layer.borderColor = self.tintColor.CGColor;
  self.layer.cornerRadius = 5.0;
  self.clipsToBounds = YES;
  [self setTitle:@"" forState:UIControlStateNormal];
  self.enabled = NO;
}

- (void)configButtonFillAndRoundedCorners {
  self.layer.borderColor = self.tintColor.CGColor;
  self.layer.cornerRadius = 5.0;
  self.clipsToBounds = YES;
  self.backgroundColor = [UIColor almostWhiteColor];
}


@end
