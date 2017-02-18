#import "QZBLoginWithEmailVC.h"
#import "QZBCurrentUser.h"
#import "TSMessage.h"
#import "UIView+QZBShakeExtension.h"
#import "QZBEmailTextField.h"
#import "QZBPasswordTextField.h"
#import "QZBUserNameTextField.h"
#import <SVProgressHUD.h>
#import <SCLAlertView-Objective-C/SCLAlertView.h>
#import "UIColor+QZBProjectColors.h"
#import "UIViewController+QZBValidateCategory.h"

@interface QZBLoginWithEmailVC () <UITextFieldDelegate>

@property (assign, nonatomic) BOOL loginInProgress;
@property (strong, nonatomic) UITextField *emailTextField;

@end

@implementation QZBLoginWithEmailVC

- (void)viewDidLoad {
  [super viewDidLoad];

  self.userNameTextField.delegate = self;
  self.passwordTextField.delegate = self;

  self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];

  self.loginInProgress = NO;
  // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self.userNameTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)keyboardWillShow:(NSNotification *)aNotification {
  NSDictionary *info = [aNotification userInfo];
  CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

  [self.view layoutIfNeeded];
  [UIView animateWithDuration:0.3
                   animations:^{
                     self.bottomSuperViewConstraint.constant = kbSize.height;
                     [self.userNameTextField.superview layoutIfNeeded];
                     [self.view layoutIfNeeded];
                   }];
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
  [self.view layoutIfNeeded];
  [UIView animateWithDuration:0.3
                   animations:^{
                     self.bottomSuperViewConstraint.constant = 0;
                     [self.view layoutIfNeeded];
                   }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before
navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)loginAction:(id)sender {
  NSString *userName = self.userNameTextField.text;
  NSString *password = self.passwordTextField.text;

  if (![self validateTextField:self.userNameTextField]) {
    [self.userNameTextField becomeFirstResponder];

    return;
  } else {
    // self.emailTextField.backgroundColor = [UIColor greenColor];
  }

  if (![self validateTextField:self.passwordTextField]) {
    [self.passwordTextField becomeFirstResponder];

    return;
  }

  __weak typeof(self) weakSelf = self;

  if (!weakSelf.loginInProgress) {
    self.loginInProgress = YES;

    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    [[QZBServerManager sharedManager] POSTLoginUserName:userName
                                               password:password
                                              onSuccess:^(QZBUser *user) {

                                                [[QZBCurrentUser sharedInstance] setUser:user];

                                                weakSelf.loginInProgress = NO;

                                                [SVProgressHUD dismiss];
                                                [self dismissViewControllerAnimated:YES
                                                                         completion:^{
                                                                         }];
                                              }
                                              onFailure:^(NSError *error, NSInteger statusCode) {

                                                if (statusCode == 401) {
                                                  [SVProgressHUD dismiss];
                                                  [TSMessage showNotificationWithTitle:[self errorAsNSString:login_fail]
                                                                                  type:TSMessageNotificationTypeError];
                                                } else {
                                                  [SVProgressHUD showInfoWithStatus:QZBNoInternetConnectionMessage];
                                                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1.5 * NSEC_PER_SEC)),
                                                      dispatch_get_main_queue(), ^{
                                                        [SVProgressHUD dismiss];
                                                      });
                                                }

                                                weakSelf.loginInProgress = NO;
                                              }];
  }
}

- (IBAction)renewPasswordAction:(id)sender {
  [self showAlertAboutPsswordRenewWithSubtitle:@"Введите почту, чтобы восстановить "
      @"аккаунт"];

  [self.userNameTextField resignFirstResponder];
  [self.passwordTextField resignFirstResponder];
}

- (void)showAlertAboutPsswordRenewWithSubtitle:(NSString *)subtitle {

  SCLAlertView *alert = [[SCLAlertView alloc] init];
  alert.backgroundType = Blur;
  alert.showAnimationType = FadeIn;

  [alert alertIsDismissed:^{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.5 * NSEC_PER_SEC)),
        dispatch_get_main_queue(), ^{
          [self setNeedsStatusBarAppearanceUpdate];
        });
  }];

  alert.completeButtonFormatBlock = ^NSDictionary *(void) {
    NSDictionary *formatDict = @{@"backgroundColor": [UIColor middleDarkGreyColor]};
    return formatDict;
  };

  self.emailTextField = [alert addTextField:@"Почта"];

  [self customizeTextField:self.emailTextField];

  [alert addButton:@"Восстановить"
   validationBlock:^BOOL {
     return [self validateEmailTextField];
   }
       actionBlock:^{
         NSString *email = [self.emailTextField.text copy];
         self.emailTextField.text = @"";

         [self showAlertWaitingForEmail:email];
       }];

  [alert showEdit:self.navigationController
            title:@"Пароль"
         subTitle:subtitle
 closeButtonTitle:@"Отмена"
         duration:0.0f];
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.3 * NSEC_PER_SEC)),
      dispatch_get_main_queue(), ^{
        [self.emailTextField becomeFirstResponder];
      });
}

- (void)showAlertWaitingForEmail:(NSString *)email {
  [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];

  [[QZBServerManager sharedManager] POSTPasswordResetWithEmail:email
                                                     onSuccess:^{

                                                       [self showAlertSucces:email];
                                                     }
                                                     onFailure:^(NSError *error, NSInteger statusCode) {
                                                       // if(alert.isVisible){
                                                       //    [alert hideView];
                                                       if (statusCode == 404) {
                                                         [SVProgressHUD dismiss];

                                                         [self showAlertFail:email];
                                                       } else {
                                                         [SVProgressHUD showErrorWithStatus:QZBNoInternetConnectionMessage];
                                                       }
                                                     }];
}

- (void)showAlertFail:(NSString *)email {
  [SVProgressHUD dismiss];
  SCLAlertView *alert = [[SCLAlertView alloc] init];
  alert.backgroundType = Blur;
  alert.showAnimationType = FadeIn;
  NSString *subTitle = [NSString stringWithFormat:@"Такая почта не привязана ни к одному из "
      @"акаунтов, попробуйте ввести другую почту"];

  __block BOOL isShown = NO;

  [alert alertIsDismissed:^{
    if (!isShown) {
      isShown = YES;
      [self showAlertAboutPsswordRenewWithSubtitle:
          @"Введите почту, чтобы восстановить "
              @"аккаунт"];
    }
  }];

  [alert showError:self.navigationController
             title:@"Ошибка"
          subTitle:subTitle
  closeButtonTitle:@"ОК"
          duration:3.0];
}

- (void)showAlertSucces:(NSString *)email {
  [SVProgressHUD dismiss];
  SCLAlertView *alert = [[SCLAlertView alloc] init];
  alert.backgroundType = Blur;
  alert.showAnimationType = FadeIn;
  NSString *subTitle = [NSString
      stringWithFormat:
          @"Сообщение с ссылкой на востановление пароля успешно "
              @"отправлено"];

  [alert showSuccess:self.navigationController
               title:@"Успешно"
            subTitle:subTitle
    closeButtonTitle:@"ОК"
            duration:5.0];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if ([textField isEqual:self.userNameTextField]) {
    if (![self validateTextField:(QZBRegistrationAndLoginTextFieldBase *) textField]) {
      return NO;
    } else {
      [self.passwordTextField becomeFirstResponder];
      return YES;
    }
  } else if ([textField isEqual:self.emailTextField]) {
    return [self validateEmailTextField];
  } else if ([textField isEqual:self.passwordTextField]) {
    if (![self validateTextField:(QZBRegistrationAndLoginTextFieldBase *) textField]) {
      return NO;
    } else {
      [self loginAction:nil];
      return YES;
    }
  }

  return NO;
}

- (BOOL)validateEmailTextField {
  if (![self validateEmailNormal:self.emailTextField.text]) {
    [self.emailTextField shakeView];

    [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, -60)];
    [SVProgressHUD showErrorWithStatus:@"Неверный формат почты"];
    [SVProgressHUD resetOffsetFromCenter];
    return NO;
  } else {
    return YES;
  }
}

- (void)customizeTextField:(UITextField *)textField {
  // self.emailTextField = textField;
  textField.delegate = self;
  textField.keyboardType = UIKeyboardTypeEmailAddress;
  textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
  textField.autocorrectionType = UITextAutocorrectionTypeNo;
  textField.spellCheckingType = UITextSpellCheckingTypeNo;
  textField.returnKeyType = UIReturnKeyDone;
}

- (void)trySendPasswordRenewWithEmail:(NSString *)email {
  [[QZBServerManager sharedManager] POSTPasswordResetWithEmail:email
                                                     onSuccess:^{
                                                     }
                                                     onFailure:^(NSError *error, NSInteger statusCode) {
                                                     }];
}

@end
