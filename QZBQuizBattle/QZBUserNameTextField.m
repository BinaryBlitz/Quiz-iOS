//
//  QZBUserNameTextField.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 20/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBUserNameTextField.h"

@implementation QZBUserNameTextField

- (BOOL)validate {
    NSString *candidate = self.text;

    return ([candidate length] <= 20 && [candidate length] >= 2);
}

@end
