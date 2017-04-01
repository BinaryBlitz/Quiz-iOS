#import <UIKit/UIKit.h>

@class JSBadgeView;

@interface QZBEndGameMainCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UIImageView *opponentImage;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *opponentNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstUserScore;
@property (weak, nonatomic) IBOutlet UILabel *opponentScore;
@property (weak, nonatomic) IBOutlet UILabel *resultOfSessionLabel;
@property (weak, nonatomic) IBOutlet UIButton *playAgainButton;
@property (weak, nonatomic) IBOutlet UIButton *chooseAnotherTopicButton;

@property (strong, nonatomic) JSBadgeView *userBV;
@property (strong, nonatomic) JSBadgeView *opponentBV;

- (void)initCell;

@end
