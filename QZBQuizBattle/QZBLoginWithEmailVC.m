//
//  QZBLoginWithEmailVCViewController.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 15/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBLoginWithEmailVC.h"
#import "QZBCurrentUser.h"
#import "QZBUser.h"
#import "TSMessage.h"
#import "UIView+QZBShakeExtension.h"
#import "QZBEmailTextField.h"
#import "QZBPasswordTextField.h"
#import "QZBUserNameTextField.h"
#import "QZBRegistrationAndLoginTextFieldBase.h"
#import <SVProgressHUD.h>

@interface QZBLoginWithEmailVC () <UITextFieldDelegate>

@property (assign, nonatomic) BOOL loginInProgress;

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

    NSLog(@"authr showed");
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
        // self.emailTextField.backgroundColor = [UIColor redColor];
        //[self shake:self.emailTextField direction:1 shakes:0];
        return;
    } else {
        // self.emailTextField.backgroundColor = [UIColor greenColor];
    }

    if (![self validateTextField:self.passwordTextField]) {
        [self.passwordTextField becomeFirstResponder];
        //[self shake:self.passwordTextField direction:1 shakes:0];
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

                // [weakSelf performSegueWithIdentifier:@"LoginIsOK" sender:nil];

                [SVProgressHUD dismiss];
                [self dismissViewControllerAnimated:YES
                                         completion:^{

                                         }];

            }
            onFailure:^(NSError *error, NSInteger statusCode) {

                NSLog(@"login fail");

                if (statusCode == 401) {
                    [SVProgressHUD dismiss];
                    [TSMessage showNotificationWithTitle:[self errorAsNSString:login_fail]
                                                    type:TSMessageNotificationTypeError];
                } else {
                    [SVProgressHUD showInfoWithStatus:QZBNoInternetConnectionMessage];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)),
                                   dispatch_get_main_queue(), ^{
                                       [SVProgressHUD dismiss];
                                   });
                }

                weakSelf.loginInProgress = NO;

            }];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.userNameTextField]) {
        if (![self validateTextField:(QZBRegistrationAndLoginTextFieldBase *)textField]) {
            return NO;
        } else {
            [self.passwordTextField becomeFirstResponder];
            return YES;
        }

    } else if ([textField isEqual:self.passwordTextField]) {
       // NSString *password = self.passwordTextField.text;

        if (![self validateTextField:(QZBRegistrationAndLoginTextFieldBase *)textField]) {
            return NO;
        } else {
           // NSString *hashed = [[QZBServerManager sharedManager] hashPassword:password];

           // NSLog(@"%@", hashed);

            [self loginAction:nil];
            return YES;
        }
    }

    return NO;
}

@end
