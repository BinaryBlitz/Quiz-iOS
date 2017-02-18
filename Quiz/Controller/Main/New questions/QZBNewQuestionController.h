#import <UIKit/UIKit.h>
#import "QZBSettingTopicProtocol.h"

@interface QZBNewQuestionController : UITableViewController <QZBSettingTopicProtocol>
//@property (weak, nonatomic) IBOutlet UITextView *inputTextView;
//@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *answersTextFields;

- (void)setUserTopic:(QZBGameTopic *)topic;

@end
