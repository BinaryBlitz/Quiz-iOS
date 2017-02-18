#import <UIKit/UIKit.h>
#import "QZBUserProtocol.h"

@class QZBAnotherUser;

@interface QZBFriendCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userpicImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (strong, nonatomic, readonly) QZBAnotherUser *user;

- (void)setCellWithUser:(id <QZBUserProtocol>)user;

@end
