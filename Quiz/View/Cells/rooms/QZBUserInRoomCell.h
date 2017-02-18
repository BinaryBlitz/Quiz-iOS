#import <UIKit/UIKit.h>

@class QZBUserWithTopic;
@class DFImageView;


@interface QZBUserInRoomCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfUserInRoomLabel;
@property (weak, nonatomic) IBOutlet UILabel *topicNameLabel;
@property (weak, nonatomic) IBOutlet DFImageView *userPicImageView;
@property (weak, nonatomic) IBOutlet UILabel *isReadyLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *isReadyActivityIndicator;
@property (weak, nonatomic) IBOutlet UIView *isReadyBackView;

- (void)configureCellWithUserWithTopic:(QZBUserWithTopic *)userWithTopic;

@end
