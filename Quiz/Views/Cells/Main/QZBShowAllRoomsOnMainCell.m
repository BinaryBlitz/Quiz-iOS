#import "QZBShowAllRoomsOnMainCell.h"
#import "UIView+QZBShakeExtension.h"

@implementation QZBShowAllRoomsOnMainCell


-(void)drawRect:(CGRect)rect {
    [self.backView addShadowsAllWay];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
