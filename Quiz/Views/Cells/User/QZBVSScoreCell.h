#import <UIKit/UIKit.h>

@class QZBAnotherUser;

@interface QZBVSScoreCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *currentUserNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentUserScoreLabel;

-(void)setCellWithUser:(QZBAnotherUser *)user;

@end
