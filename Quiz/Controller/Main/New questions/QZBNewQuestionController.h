#import <UIKit/UIKit.h>
#import "QZBSettingTopicProtocol.h"

@interface QZBNewQuestionController : UITableViewController <QZBSettingTopicProtocol>

- (void)setUserTopic:(QZBGameTopic *)topic;

@end
