#import <UIKit/UIKit.h>
#import "QZBUserProtocol.h"

@interface QZBReportVC : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *reportButton;
@property (weak, nonatomic) IBOutlet UITextView *reportTextView;

- (void)initWithUser:(id <QZBUserProtocol>)user;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonBottomSpaceConstraint;

@end
