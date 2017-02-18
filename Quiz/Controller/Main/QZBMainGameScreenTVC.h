#import <UIKit/UIKit.h>
#import "QZBTopicChooserController.h"

@interface QZBMainGameScreenTVC : QZBTopicChooserController
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
-(void)reloadTopicsData;

@end
