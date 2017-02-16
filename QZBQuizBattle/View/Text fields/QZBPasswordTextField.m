//
//  QZBPasswordTextField.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 20/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBPasswordTextField.h"

@implementation QZBPasswordTextField

- (BOOL)validate {
    return ([self.text length] >= 6);
}

@end
