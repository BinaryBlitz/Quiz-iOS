#import <UIKit/UIKit.h>
#import "QZBSettingTopicProtocol.h"

@class QZBRoom;
@class QZBGameTopic;

@interface QZBRoomController : UITableViewController <QZBSettingTopicProtocol>

- (void)initWithRoom:(QZBRoom *)room;
- (void)setUserTopic:(QZBGameTopic *)topic;

@end
