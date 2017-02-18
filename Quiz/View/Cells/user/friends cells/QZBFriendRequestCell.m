#import "QZBFriendRequestCell.h"
#import "UIButton+QZBButtonCategory.h"


@implementation QZBFriendRequestCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)awakeFromNib{
    
    [self.acceptButton
     configButtonWithRoundedBorders];
    
    [self.acceptButton setTitle:@"Принять"
                       forState:UIControlStateNormal];
    self.acceptButton.enabled = YES;
    
    [self.declineButton configButtonFillAndRoundedCorners];
    
    [self.declineButton setExclusiveTouch:YES];
    [self.acceptButton setExclusiveTouch:YES];
    
}

@end
