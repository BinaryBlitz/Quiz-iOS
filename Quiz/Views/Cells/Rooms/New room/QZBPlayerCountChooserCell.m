#import "QZBPlayerCountChooserCell.h"
#import "UIFont+QZBCustomFont.h"

@implementation QZBPlayerCountChooserCell


-(void)awakeFromNib{
  NSDictionary *attributes = @{NSFontAttributeName:[UIFont museoFontOfSize:25]};
  [self.playersCountSegmentControll setTitleTextAttributes:attributes
                                                  forState:UIControlStateNormal];
  [self.playersCountSegmentControll setTitleTextAttributes:attributes forState:UIControlStateSelected];
}

@end
