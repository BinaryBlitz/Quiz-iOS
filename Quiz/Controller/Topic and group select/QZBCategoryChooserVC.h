#import <UIKit/UIKit.h>
#import "QZBUserProtocol.h"

@interface QZBCategoryChooserVC : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;

-(void)initWithUser:(id<QZBUserProtocol>) user;

@end
