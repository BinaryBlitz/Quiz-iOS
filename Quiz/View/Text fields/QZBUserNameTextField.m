#import "QZBUserNameTextField.h"

@implementation QZBUserNameTextField

- (BOOL)validate {
    NSString *candidate = self.text;
    
    NSString *nameRegex =
    @"[A-Z0-9a-z_]{2,20}";  //([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})
    NSPredicate *nameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", nameRegex];
    return [nameTest evaluateWithObject:candidate];
}

@end
