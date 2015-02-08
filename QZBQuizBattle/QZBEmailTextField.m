//
//  QZBEmailTextField.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 20/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBEmailTextField.h"

@implementation QZBEmailTextField

- (BOOL)validate {
    NSString *candidate = self.text;

    NSString *emailRegex =
        @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";  //([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];

    return [emailTest evaluateWithObject:candidate];
}

@end
