#import <UIKit/UIKit.h>
#import "QZBSettingTopicProtocol.h"

@interface QZBCreateRoomController : UITableViewController <QZBSettingTopicProtocol>

- (void)setUserTopic:(QZBGameTopic *)topic;

@end
