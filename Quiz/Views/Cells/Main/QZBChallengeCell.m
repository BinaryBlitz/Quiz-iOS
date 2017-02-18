#import "QZBChallengeCell.h"
#import "UIView+QZBShakeExtension.h"

@implementation QZBChallengeCell

-(void)drawRect:(CGRect)rect{
    [self.backView addShadowsAllWay];
    [self.underView addShadowsAllWayRasterize];
}

-(void)awakeFromNib{
// //   [self.backView addShadowsAllWay];
// //   [self.underView addShadowsAllWayRasterize];
}

@end
