#import "QZBStoreBoosterCell.h"
#import "UIButton+QZBButtonCategory.h"

@implementation QZBStoreBoosterCell

- (void)awakeFromNib {
  //  [self.purchaseButton configButtonWithRoundedBorders];
    self.layer.cornerRadius = 5.0;
    self.clipsToBounds = YES;
    
}

@end
