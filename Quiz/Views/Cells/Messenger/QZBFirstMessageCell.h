#import "QZBFriendCell.h"

@class QZBAnotherUserWithLastMessages;

@interface QZBFirstMessageCell : QZBFriendCell

@property (weak, nonatomic) IBOutlet UILabel *firstMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

- (void)setCellWithUserWithLastMessage:(QZBAnotherUserWithLastMessages *)userAndMessage;


@end
