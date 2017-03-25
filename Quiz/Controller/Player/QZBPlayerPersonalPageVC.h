#import <UIKit/UIKit.h>
#import "QZBUserProtocol.h"

@interface QZBPlayerPersonalPageVC : UITableViewController

@property (strong, nonatomic) IBOutlet UITableView *playerTableView;

- (void)initPlayerPageWithUser:(id <QZBUserProtocol>)user;

@end
