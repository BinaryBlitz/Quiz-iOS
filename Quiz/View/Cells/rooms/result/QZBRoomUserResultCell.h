#import <UIKit/UIKit.h>
@class QZBUserWithTopic;

@interface QZBRoomUserResultCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *userPositionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userpicImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userPointsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cupImageView;
@property (weak, nonatomic) IBOutlet UILabel *waitingLabel;

-(void)confirureWithUserWithTopic:(QZBUserWithTopic *)userWithTopic position:(NSNumber *)position;

@end
