#import <UIKit/UIKit.h>
#import "QZBUserProtocol.h"

@class QZBCategory;
@class QZBGameTopic;

@interface QZBRatingMainVC : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *chooseTopicButton;
@property (weak, nonatomic) IBOutlet UIView *buttonsBackgroundView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeChooserSegmentControl;
@property (strong, nonatomic) UIView *buttonBackgroundView;
@property (strong, nonatomic) QZBCategory *category;
@property (strong, nonatomic) QZBGameTopic *topic;

- (void)showUserPage:(id <QZBUserProtocol>)user;
- (void)initWithTopic:(QZBGameTopic *)topic;
- (void)createButtonBackgroundView;

@end
