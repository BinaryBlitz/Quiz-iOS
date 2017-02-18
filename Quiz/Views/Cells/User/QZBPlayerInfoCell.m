#import "QZBPlayerInfoCell.h"
#import <JSBadgeView/JSBadgeView.h>
#import "UITableViewCell+QZBCellCategory.h"
#import "UIButton+Badge.h"

@interface QZBPlayerInfoCell ()

@property(strong, nonatomic) JSBadgeView *badgeView;
@property(strong, nonatomic) JSBadgeView *messageBadgeView;

@end

@implementation QZBPlayerInfoCell

- (void)awakeFromNib {
  UIEdgeInsets edgeInset = UIEdgeInsetsMake(10, 10, 10, 10);

  self.playerUserpic.userInteractionEnabled = YES;

  self.multiUseButton.titleLabel.adjustsFontSizeToFitWidth = YES;
  self.multiUseButton.titleLabel.minimumScaleFactor = 0.5;
  self.multiUseButton.titleLabel.lineBreakMode = NSLineBreakByClipping;

  self.messageButton.titleLabel.adjustsFontSizeToFitWidth = YES;
  self.messageButton.titleLabel.minimumScaleFactor = 0.5;
  self.messageButton.titleLabel.lineBreakMode = NSLineBreakByClipping;

  self.messageButton.titleLabel.numberOfLines = 1;

  self.messageButton.titleEdgeInsets = edgeInset;
  self.multiUseButton.titleEdgeInsets = edgeInset;

  self.achievementLabel.text = @"";
}

-(void)setBAdgeCount:(NSInteger)count{
  if(count <= 0){
    self.friendsButton.badgeValue = nil;
  } else{

    self.friendsButton.badgeOriginX = 3*self.friendsButton.bounds.size.width/4;
    self.friendsButton.badgeOriginY = self.friendsButton.bounds.size.height/5;
    self.friendsButton.badgeMinSize = 10;

    self.friendsButton.badgeValue = [NSString stringWithFormat:@"%ld", (long)count];
  }
}

-(void)setMessageBadgeCount:(NSInteger)count{
  if(count <= 0){
    self.messageBadgeView.badgeText = nil;
  } else{
    self.messageBadgeView.badgeText = [NSString stringWithFormat:@"%ld", (long)count];
  }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
}

-(JSBadgeView *)messageBadgeView{
  if(!_messageBadgeView){
    _messageBadgeView = [[JSBadgeView alloc] initWithParentView:self.messageButton
                                                      alignment:JSBadgeViewAlignmentTopRight];
  }
  return _messageBadgeView;
}

@end
