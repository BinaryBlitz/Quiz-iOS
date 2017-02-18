#import "QZBFriendCell.h"
#import "QZBAnotherUser.h"
#import "UIImageView+AFNetworking.h"
#import "UIFont+QZBCustomFont.h"
#import "UIColor+QZBProjectColors.h"

@interface QZBFriendCell ()

@property(strong, nonatomic) QZBAnotherUser *user;

@end

@implementation QZBFriendCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
}


-(void)setCellWithUser:(id<QZBUserProtocol>)user{

  self.user = user;

  self.nameLabel.text = user.name;

  if([self.user respondsToSelector:@selector(isOnline)]) {

    if(self.user.isOnline){
      self.userpicImageView.layer.borderColor = [UIColor lightBlueColor].CGColor;
      self.userpicImageView.layer.borderWidth = 2.0;
    } else {
      self.userpicImageView.layer.borderColor = [UIColor clearColor].CGColor;
      self.userpicImageView.layer.borderWidth = 0.0;
    }
  }

  self.nameLabel.font = [UIFont museoFontOfSize:17.0];
}

@end
