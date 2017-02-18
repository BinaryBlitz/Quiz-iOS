#import <UIKit/UIKit.h>

@class QZBGameTopic;
@interface QZBQuestionReportTVC : UITableViewController

- (void)configureWithQuestions:(NSArray *)questions topic:(QZBGameTopic *)topic;

@end
