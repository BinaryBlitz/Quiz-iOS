#import <UIKit/UIKit.h>

@interface QZBPlayerInfoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *playerUserpic;
@property (weak, nonatomic) IBOutlet UIButton *multiUseButton;
@property (weak, nonatomic) IBOutlet UIButton *friendsButton;
@property (weak, nonatomic) IBOutlet UIButton *achievmentsButton;
@property (weak, nonatomic) IBOutlet UILabel *friendsLabel;
@property (weak, nonatomic) IBOutlet UILabel *achievementLabel;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;

- (void)setBAdgeCount:(NSInteger)count;
- (void)setMessageBadgeCount:(NSInteger)count;

@end
