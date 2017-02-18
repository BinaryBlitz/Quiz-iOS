#import <UIKit/UIKit.h>
#import "QZBRegisterAndLoginBaseVC.h"

@class QZBUserNameTextField;

@interface QZBRegistrationUsernameInput : QZBRegisterAndLoginBaseVC

@property (weak, nonatomic) IBOutlet QZBUserNameTextField *usernameTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSuperViewConstraint;

- (void)setUSerWhithoutUsername:(QZBUser *)user;

@end
