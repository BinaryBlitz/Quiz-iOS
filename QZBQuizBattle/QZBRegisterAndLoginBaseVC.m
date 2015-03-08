//
//  QZBRegisterAndLoginBaseVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 15/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRegisterAndLoginBaseVC.h"
#import "QZBRegistrationAndLoginTextFieldBase.h"
#import "QZBEmailTextField.h"
#import "QZBPasswordTextField.h"
#import "QZBUserNameTextField.h"
#import "TSMessage.h"
#import "UIView+QZBShakeExtension.h"

@interface QZBRegisterAndLoginBaseVC ()

@end

@implementation QZBRegisterAndLoginBaseVC

- (void)viewDidLoad {
    [super viewDidLoad];

    //[TSMessage setDefaultViewController:self.navigationController];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [TSMessage setDefaultViewController:self.navigationController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [TSMessage dismissActiveNotification];
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

#pragma mark - validation

- (BOOL)validateEmail:(NSString *)candidate {
    NSString *emailRegex =
        @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";  //([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];

    return [emailTest evaluateWithObject:candidate];
}

- (BOOL)validatePassword:(NSString *)candidate {
    return ([candidate length] >= 6);
}

- (BOOL)validateUsername:(NSString *)candidate {
    return ([candidate length] <= 20 && [candidate length] >= 2);
}

#pragma mark - shake

- (void)shake:(UIView *)theOneYouWannaShake direction:(int)direction shakes:(int)shakes {
    [UIView animateWithDuration:0.03
        animations:^{
            theOneYouWannaShake.transform = CGAffineTransformMakeTranslation(5 * direction, 0);
        }
        completion:^(BOOL finished) {
            if (shakes >= 10) {
                theOneYouWannaShake.transform = CGAffineTransformIdentity;
                return;
            }
            __block int shakess = shakes;
            shakess++;
            __block int directionn = direction;
            directionn = directionn * -1;
            [self shake:theOneYouWannaShake direction:directionn shakes:shakess];
        }];
}

#pragma mark - errors

- (NSString *)errorAsNSString:(QZBLoginErrors)errorType {
    NSString *result = nil;

    // NSString *password_error_message = @"Пароль должен быть длинее 5 символов";
    // NSString *username_short_error_message = @"Имя должно быть длинее 1 символа";
    // NSString *username_long_error_message = @"Имя должно быть короче 20 символов";
    // NSString *email_error_message = @"Неверный формат почты";

    switch (errorType) {
        case email_error_message:
            result = @"Неверный формат почты";
            break;
        case password_error_message:
            result = @"Пароль должен быть длинее 5 символов";
            break;
        case username_short_error_message:
            result = @"Имя должно быть длинее 1 символа";
            break;
        case username_long_error_message:
            result = @"Имя должно быть короче 20 символов";
            break;
        case user_alredy_exist:
            result = @"Пользователь с такой почтой уже "
                     @"зарегистрирован";
            break;
        case login_fail:
            result = @"Неверная почта или пароль";

        default:
            break;
    }
    return result;
}

- (BOOL)validateTextField:(QZBRegistrationAndLoginTextFieldBase *)textField {
    if ([textField isKindOfClass:[QZBEmailTextField class]]) {
        if (![textField validate]) {
            [TSMessage showNotificationWithTitle:[self errorAsNSString:email_error_message]
                                            type:TSMessageNotificationTypeWarning];
            [textField shakeView];
            return NO;
        } else {
            return YES;
        }

    } else if ([textField isKindOfClass:[QZBPasswordTextField class]]) {
        if (![textField validate]) {
            [TSMessage showNotificationWithTitle:[self errorAsNSString:password_error_message]
                                            type:TSMessageNotificationTypeWarning];
            [textField shakeView];
            return NO;

        } else {
            return YES;
        }

    } else if ([textField isKindOfClass:[QZBUserNameTextField class]]) {
        if (![textField validate]) {
            if ([textField.text length] < 2) {
                [TSMessage
                    showNotificationWithTitle:[self errorAsNSString:username_short_error_message]
                                         type:TSMessageNotificationTypeWarning];
            } else if ([textField.text length] > 20) {
                [TSMessage
                    showNotificationWithTitle:[self errorAsNSString:username_long_error_message]
                                         type:TSMessageNotificationTypeWarning];
            }

            [textField shakeView];
            return NO;

        } else {
            return YES;
        }

    }

    else {
        return NO;
    }
}


- (IBAction)dismisVC:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}



@end
