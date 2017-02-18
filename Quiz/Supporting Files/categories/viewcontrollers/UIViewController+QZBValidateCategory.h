#import <UIKit/UIKit.h>

@class QZBRegistrationAndLoginTextFieldBase;

@interface UIViewController (QZBValidateCategory)

typedef enum {
  password_error_message,
  username_short_error_message,
  username_long_error_message,
  username_wrong_char_message,
  email_error_message,
  user_alredy_exist,
  login_fail
} QZBLoginErrors;

- (BOOL)validateTextField:(QZBRegistrationAndLoginTextFieldBase *)textField;

- (NSString *)errorAsNSString:(QZBLoginErrors)errorType;

- (BOOL)validateEmailNormal:(NSString *)candidate;

- (BOOL)validatePassword:(NSString *)candidate;

- (BOOL)validateUsername:(NSString *)candidate;

- (BOOL)validateEmail:(NSString *)candidate;

@end
