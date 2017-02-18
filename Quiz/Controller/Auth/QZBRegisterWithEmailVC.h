#import <UIKit/UIKit.h>
#import "QZBRegisterAndLoginBaseVC.h"

@class QZBPasswordTextField;
@class QZBEmailTextField;
@class QZBUserNameTextField;

@interface QZBRegisterWithEmailVC : QZBRegisterAndLoginBaseVC

@property (weak, nonatomic) IBOutlet QZBUserNameTextField *userNameTextField;
@property (weak, nonatomic) IBOutlet QZBEmailTextField *emailTextField;
@property (weak, nonatomic) IBOutlet QZBPasswordTextField *passwordTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSuperViewConstraint;

@end
