#import <UIKit/UIKit.h>

@class QZBAnotherUser;

@interface QZBVSScoreCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *currentUserNameLabel;

//@property (weak, nonatomic) IBOutlet UILabel *anotherUserNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *currentUserScoreLabel;

//@property (weak, nonatomic) IBOutlet UILabel *opponentUserScoreLabel;

-(void)setCellWithUser:(QZBAnotherUser *)user;


@end
