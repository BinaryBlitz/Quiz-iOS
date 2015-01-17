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

@interface QZBRegisterWithEmailVC () <UITextFieldDelegate>

@end

@implementation QZBRegisterWithEmailVC

- (void)viewDidLoad {
  [super viewDidLoad];

  self.userNameTextField.delegate = self;
  self.emailTextField.delegate = self;
  self.passwordTextField.delegate = self;
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

  if (![self validateUsername:username]) {
    [self.userNameTextField becomeFirstResponder];
    //self.userNameTextField.backgroundColor = [UIColor redColor];
    
    [self shake:self.userNameTextField direction:1 shakes:0];
    return;
  } else {
    //self.userNameTextField.backgroundColor = [UIColor greenColor];
  }

  if (![self validateEmail:email]) {
    [self.emailTextField becomeFirstResponder];
    //self.emailTextField.backgroundColor = [UIColor redColor];
    [self shake:self.emailTextField direction:1 shakes:0];
    return;
  } else {
    //self.emailTextField.backgroundColor = [UIColor greenColor];
  }
  
  if(![self validatePassword:password]){
    [self.passwordTextField becomeFirstResponder];
    [self shake:self.passwordTextField direction:1 shakes:0];
    return;
    
  }

  __weak typeof(self) weakSelf = self;
  
  if([self validateEmail:email] && [self validatePassword:password] && [self validateUsername:username]){
  
  [[QZBServerManager sharedManager] POSTRegistrationUser:username
      email:email
      password:password
      onSuccess:^(QZBUser *user) {
        NSLog(@"user %@", user.api_key);
        [[QZBCurrentUser sharedInstance] setUser:user];
        [weakSelf performSegueWithIdentifier:@"registrationIsOk" sender:nil];
        
      }
      onFailure:^(NSError *error, NSInteger statusCode){

        if(statusCode == 422){
          [weakSelf userAlreadyExist];
        }
        
      }];
  }
}

-(void)userAlreadyExist{
  [TSMessage showNotificationWithTitle:@"user already exist" type:TSMessageNotificationTypeError];

  NSLog(@"UserAlredyExist");
  
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if ([textField isEqual:self.userNameTextField]) {
    NSString *username = self.userNameTextField.text;
   
    
    if (![self validateUsername:username]) {
      
      //direction = 1;
      //shakes = 0;
      [self shake:self.userNameTextField direction:1 shakes:0];
      return NO;

    } else {
      [self.emailTextField becomeFirstResponder];
      return YES;
    }
  } else if ([textField isEqual:self.emailTextField]){
    NSString *email = self.emailTextField.text;
    
    if (![self validateEmail:email]){
      //direction = 1;
      //shakes = 0;
      [self shake:self.emailTextField direction:1 shakes:0];
      return NO;
    }else{
      [self.passwordTextField becomeFirstResponder];
      return YES;
    }
    
  } else if([textField isEqual:self.passwordTextField]){
    NSString *password = self.passwordTextField.text;
    
    if (![self validatePassword:password]){
      //direction = 1;
      //shakes = 0;
      [self shake:self.passwordTextField direction:1 shakes:0];
      return NO;
    }else{
      [self registerAction:nil];
      return YES;
    }
    
  }

  return NO;
}


@end
