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

@interface QZBLoginWithEmailVC ()<UITextFieldDelegate>

@end

@implementation QZBLoginWithEmailVC

- (void)viewDidLoad {
    [super viewDidLoad];
  
  self.emailTextField.delegate = self;
  self.passwordTextField.delegate = self;
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{
  [self.emailTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)loginAction:(id)sender {
  
  NSString *email = self.emailTextField.text;
  NSString *password = self.passwordTextField.text;
  
  
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

  [[QZBServerManager sharedManager] POSTLoginUserEmail:email password:password onSuccess:^(QZBUser *user) {
    
    [[QZBCurrentUser sharedInstance] setUser:user];
    
    [weakSelf performSegueWithIdentifier:@"LoginIsOK" sender:nil];
    
  } onFailure:^(NSError *error, NSInteger statusCode) {
    
  }];
  
  
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

if ([textField isEqual:self.emailTextField]){
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
    
    NSString *hashed = [[QZBServerManager sharedManager] hashPassword:password];
    
    NSLog(@"%@", hashed);
    
    [self loginAction:nil];
    return YES;
  }
  
}

return NO;
}

@end
