//
//  QZBRegisterWithEmailVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 15/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRegisterWithEmailVC.h"
#import "QZBCurrentUser.h"
#import "TSMessage.h"
#import "QZBUserNameTextField.h"
#import "QZBEmailTextField.h"
#import "QZBPasswordTextField.h"
#import "UIView+QZBShakeExtension.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface QZBRegisterWithEmailVC () <UITextFieldDelegate>

@property (assign, nonatomic) BOOL registrationInProgress;

@end

@implementation QZBRegisterWithEmailVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.userNameTextField.delegate = self;
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.registrationInProgress = NO;

    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];

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
                         [self.emailTextField.superview layoutIfNeeded];
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

// In a storyboard-based application, you will often want to do a little
preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - actions

- (IBAction)registerAction:(UIBarButtonItem *)sender {
    NSString *username = self.userNameTextField.text;
    NSString *email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;

    if (![self validateTextField:self.userNameTextField]) {
        [self.userNameTextField becomeFirstResponder];

        return;
    } else {
    }

    if (![self validateTextField:self.emailTextField]) {
        [self.emailTextField becomeFirstResponder];

        return;
    } else {
    }

    if (![self validateTextField:self.passwordTextField]) {
        [self.passwordTextField becomeFirstResponder];

        return;
    }

    __weak typeof(self) weakSelf = self;

    if ([self validateEmail:email] && [self validatePassword:password] &&
        [self validateUsername:username] && !self.registrationInProgress) {
        self.registrationInProgress = YES;

        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
        [[QZBServerManager sharedManager] POSTRegistrationUser:username
            email:email
            password:password
            onSuccess:^(QZBUser *user) {
                [[QZBCurrentUser sharedInstance] setUser:user];

                weakSelf.registrationInProgress = NO;

                [SVProgressHUD dismiss];
                [self dismissViewControllerAnimated:YES
                                         completion:^{
                                         }];
            }
            onFailure:^(NSError *error, NSInteger statusCode, QZBUserRegistrationProblem problem) {

                if (statusCode == 422) {
                    [SVProgressHUD dismiss];
                    [weakSelf userAlreadyExist:problem];
                } else {
                    [SVProgressHUD showInfoWithStatus:QZBNoInternetConnectionMessage];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),
                                   dispatch_get_main_queue(), ^{
                                       [SVProgressHUD dismiss];
                                   });
                }

                weakSelf.registrationInProgress = NO;

            }];
    }
}

- (void)userAlreadyExist:(QZBUserRegistrationProblem)problem {
    NSString *message = @"";
    switch (problem) {
        case QZBUserNameProblem:
            message = @"Пользователь с таким именем уже существует, введите другое "
                      @"имя";
            [self.userNameTextField becomeFirstResponder];
            break;
        case QZBEmailProblem:
            message = @"Пользователь с такой почтой уже существует, введите другую "
                      @"почту";
            [self.emailTextField becomeFirstResponder];
            break;

        default:
            break;
    }

    [TSMessage showNotificationWithTitle:message type:TSMessageNotificationTypeError];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.userNameTextField]) {
        if (![self validateTextField:(QZBRegistrationAndLoginTextFieldBase *)textField]) {
            return NO;

        } else {
            [self.emailTextField becomeFirstResponder];
            return YES;
        }
    } else if ([textField isEqual:self.emailTextField]) {
        if (![self validateTextField:(QZBRegistrationAndLoginTextFieldBase *)textField]) {
            return NO;
        } else {
            [self.passwordTextField becomeFirstResponder];
            return YES;
        }

    } else if ([textField isEqual:self.passwordTextField]) {
        if (![self validateTextField:(QZBRegistrationAndLoginTextFieldBase *)textField]) {
            return NO;
        } else {
            [self registerAction:nil];
            return YES;
        }
    }

    return NO;
}

@end
