//
//  QZBRegistrationUsernameInput.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 12/04/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRegistrationUsernameInput.h"
#import "QZBUserNameTextField.h"
#import <TSMessages/TSMessage.h>
#import "QZBCurrentUser.h"
#import <SVProgressHUD.h>
#import "UIViewController+QZBValidateCategory.h"

@interface QZBRegistrationUsernameInput () <UITextFieldDelegate>

@property (assign, nonatomic) BOOL loginInPRogress;
@property (strong, nonatomic) QZBUser *user;
@property (assign, nonatomic) BOOL registrationInProgress;

@end

@implementation QZBRegistrationUsernameInput

- (void)viewDidLoad {
    [super viewDidLoad];

    self.usernameTextField.delegate = self;

    // [self registerForKeyboardNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.usernameTextField becomeFirstResponder];
}

- (void)setUSerWhithoutUsername:(QZBUser *)user {
    self.user = user;
}


- (void)keyboardWillShow:(NSNotification *)aNotification {
    NSDictionary *info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.bottomSuperViewConstraint.constant = kbSize.height;
                         //   [self.usernameTextField.superview layoutIfNeeded];
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

#pragma mark - actions

- (IBAction)loginAction:(id)sender {
    NSString *username = [self.usernameTextField.text copy];

    if (![self validateTextField:self.usernameTextField]) {
        [self.usernameTextField becomeFirstResponder];

        return;
    } else {
        if (!self.registrationInProgress) {
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
            self.registrationInProgress = YES;
            [[QZBServerManager sharedManager] PATCHPlayerWithNewUserNameThenRegistration:username
                user:self.user
                onSuccess:^{

                    [self.user makeUserRegisterWithUserName:username];

                    [[QZBCurrentUser sharedInstance] setUser:self.user];

                    self.registrationInProgress = NO;

                    //[weakSelf performSegueWithIdentifier:@"registrationIsOk" sender:nil];

                    [SVProgressHUD dismiss];
                    [self dismissViewControllerAnimated:YES
                                             completion:^{
                                             }];

                    self.registrationInProgress = NO;
                }
                onFailure:^(NSError *error, NSInteger statusCode,
                            QZBUserRegistrationProblem problem) {
                    self.registrationInProgress = NO;
                    [SVProgressHUD dismiss];
                    if (problem == QZBUserNameProblem) {
                        [TSMessage showNotificationWithTitle:@"Это имя уже занято"
                                                        type:TSMessageNotificationTypeWarning];

                    } else {
                        [TSMessage showNotificationWithTitle:
                                       @"Имя не обновлено, проверьте "
                                   @"интернет-соединение"
                                                        type:TSMessageNotificationTypeWarning];
                    }

                }];
        }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //  [textField layoutSubviews];

    if ([textField isEqual:self.usernameTextField]) {
        if (![self validateTextField:(QZBRegistrationAndLoginTextFieldBase *)textField]) {
            return NO;

        } else {
            [self loginAction:nil];

            return YES;
        }
    }
    return NO;
}

@end
