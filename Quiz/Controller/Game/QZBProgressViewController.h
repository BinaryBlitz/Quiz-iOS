#import <UIKit/UIKit.h>
#import "QZBUserProtocol.h"

@class QZBGameTopic;
@class QZBSession;
@class QZBChallengeDescription;
@class SVIndefiniteAnimatedView;

@interface QZBProgressViewController : UIViewController

@property (strong, nonatomic) QZBGameTopic *topic;

// For subclassing
@property (assign, nonatomic) BOOL isChallenge;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelCrossButton;
@property (weak, nonatomic) IBOutlet UILabel *topicLabel;
@property (weak, nonatomic) IBOutlet UILabel *factLabel;
@property (weak, nonatomic) IBOutlet SVIndefiniteAnimatedView *backView;
@property (strong, nonatomic) SVIndefiniteAnimatedView *animationView;

- (void)settitingSession:(QZBSession *)session bot:(id)bot;
- (void)initSession;
- (void)closeFinding;
- (void)initSessionWithTopic:(QZBGameTopic *)topic user:(id <QZBUserProtocol>)user;
- (void)initPlayAgainSessionWithTopic:(QZBGameTopic *)topic user:(id <QZBUserProtocol>)user;
- (void)initSessionWithDescription:(QZBChallengeDescription *)description;

@property (weak, nonatomic) IBOutlet UIButton *playOfflineButton;

@end
