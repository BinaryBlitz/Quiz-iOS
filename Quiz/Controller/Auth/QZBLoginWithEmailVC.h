#import "QZBRegisterAndLoginBaseVC.h"

@class QZBEmailTextField;
@class QZBPasswordTextField;
@class QZBUserNameTextField;

@interface QZBLoginWithEmailVC : QZBRegisterAndLoginBaseVC

//@property (weak, nonatomic) IBOutlet QZBEmailTextField *emailTextField;
@property (weak, nonatomic) IBOutlet QZBPasswordTextField *passwordTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSuperViewConstraint;
@property (weak, nonatomic) IBOutlet QZBUserNameTextField *userNameTextField;


@end
