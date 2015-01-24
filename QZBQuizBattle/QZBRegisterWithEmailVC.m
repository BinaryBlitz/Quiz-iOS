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

@interface QZBRegisterWithEmailVC () <UITextFieldDelegate>

@property(assign, nonatomic) BOOL registrationInProgress;

@end

@implementation QZBRegisterWithEmailVC

- (void)viewDidLoad {
  [super viewDidLoad];

  self.userNameTextField.delegate = self;
  self.emailTextField.delegate = self;
  self.passwordTextField.delegate = self;
  self.registrationInProgress = NO;
  // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{
  [self.userNameTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
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
  
  if(![self validateTextField:self.passwordTextField]){
    [self.passwordTextField becomeFirstResponder];

    return;
    
  }

  __weak typeof(self) weakSelf = self;
  
  if([self validateEmail:email] && [self validatePassword:password] && [self validateUsername:username] && !self.registrationInProgress){
    self.registrationInProgress = YES;
    
  [[QZBServerManager sharedManager] POSTRegistrationUser:username
         email:email
      password:password
      onSuccess:^(QZBUser *user) {
        NSLog(@"user %@", user.api_key);
        [[QZBCurrentUser sharedInstance] setUser:user];
        
        weakSelf.registrationInProgress = NO;
        
        [weakSelf performSegueWithIdentifier:@"registrationIsOk" sender:nil];
        
      }
      onFailure:^(NSError *error, NSInteger statusCode){

        if(statusCode == 422){
          [weakSelf userAlreadyExist];
        }
        
        weakSelf.registrationInProgress = NO;
        
      }];
  }
}

-(void)userAlreadyExist{
  [TSMessage showNotificationWithTitle:[self errorAsNSString:user_alredy_exist]
                                  type:TSMessageNotificationTypeError];
  
  [self.emailTextField becomeFirstResponder];

  NSLog(@"UserAlredyExist");
  
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
  } else if ([textField isEqual:self.emailTextField]){
    
    if (![self validateTextField:(QZBRegistrationAndLoginTextFieldBase *)textField]){
      return NO;
    }else{
      [self.passwordTextField becomeFirstResponder];
      return YES;
    }
    
  } else if([textField isEqual:self.passwordTextField]){

    
    if (![self validateTextField:(QZBRegistrationAndLoginTextFieldBase *)textField]){
      return NO;
    }else{
      [self registerAction:nil];
      return YES;
    }
    
  }

  return NO;
}



//-(void)TextFieldIsNotOK:(UITextField *)textField


@end
