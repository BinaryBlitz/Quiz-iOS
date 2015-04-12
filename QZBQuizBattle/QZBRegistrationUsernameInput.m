//
//  QZBRegistrationUsernameInput.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 12/04/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRegistrationUsernameInput.h"
#import "QZBUserNameTextField.h"

@interface QZBRegistrationUsernameInput() <UITextFieldDelegate>

@property(assign, nonatomic) BOOL loginInPRogress;

@end

@implementation QZBRegistrationUsernameInput

-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.usernameTextField.delegate = self;
    
   // [self registerForKeyboardNotifications];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self.usernameTextField becomeFirstResponder];
}




//- (void)registerForKeyboardNotifications {
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillShow:)
//                                                 name:UIKeyboardWillShowNotification
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillHide:)
//                                                 name:UIKeyboardWillHideNotification
//                                               object:nil];
//}
//
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
    NSLog(@"login action");
    
    if (![self validateTextField:self.usernameTextField]) {
        [self.usernameTextField becomeFirstResponder];
        
        return;
    }else{
        
    }
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
  //  [textField layoutSubviews];
    
    if ([textField isEqual:self.usernameTextField]) {
        if (![self validateTextField:(QZBRegistrationAndLoginTextFieldBase *)textField]) {
            return NO;
            
        } else {
           // [self.emailTextField becomeFirstResponder];
            
            [self loginAction:nil];
            return YES;
        }
    }
    return NO;
    
}

@end
