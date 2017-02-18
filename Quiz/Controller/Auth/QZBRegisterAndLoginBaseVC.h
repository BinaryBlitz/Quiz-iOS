#import <UIKit/UIKit.h>
#import "QZBServerManager.h"
#import "QZBUser.h"

@class QZBRegistrationAndLoginTextFieldBase;
@interface QZBRegisterAndLoginBaseVC : UIViewController



//typedef enum {
//    password_error_message,
//    username_short_error_message,
//    username_long_error_message,
//    username_wrong_char_message,
//    email_error_message,
//    user_alredy_exist,
//    login_fail
//} QZBLoginErrors;

//- (BOOL)validateEmail:(NSString *)candidate;
//- (BOOL)validateEmailNormal:(NSString *)candidate;
//- (BOOL)validatePassword:(NSString *)candidate;
//- (BOOL)validateUsername:(NSString *)candidate;
//
//- (BOOL)validateTextField:(QZBRegistrationAndLoginTextFieldBase *)textField;

- (void)shake:(UIView *)theOneYouWannaShake direction:(int)direction shakes:(int)shakes;

//- (NSString *)errorAsNSString:(QZBLoginErrors)errorType;

// NSString *password_error_message = @"Пароль должен быть длинее 5 символов";
// NSString *username_short_error_message = @"Имя должно быть длинее 1 символа";
// NSString *username_long_error_message = @"Имя должно быть короче 20 символов";
// NSString *email_error_message = @"Неверный формат почты";

@end
