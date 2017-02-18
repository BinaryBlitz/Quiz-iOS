#import <UIKit/UIKit.h>

@class QZBChallengeDescriptionWithResults;

@interface QZBEndGameVC : UITableViewController
//@property (weak, nonatomic) IBOutlet UITableView *tableView;
//@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

- (void)initWithChallengeResult:(QZBChallengeDescriptionWithResults *)challengeDescription;

@end
