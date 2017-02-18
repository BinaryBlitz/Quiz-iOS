#import <UIKit/UIKit.h>

@interface QZBChallengeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *topicNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *opponentNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *declineButton;

@property (weak, nonatomic) IBOutlet UIView *underView;
@property (weak, nonatomic) IBOutlet UIView *backView;


@end
