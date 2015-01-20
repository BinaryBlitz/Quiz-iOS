//
//  QZBRegisterWithEmailVC.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 15/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QZBRegisterAndLoginBaseVC.h"
@class QZBPasswordTextField;
@class QZBEmailTextField;
@class QZBUserNameTextField;
@interface QZBRegisterWithEmailVC : QZBRegisterAndLoginBaseVC

@property (weak, nonatomic) IBOutlet QZBUserNameTextField *userNameTextField;
@property (weak, nonatomic) IBOutlet QZBEmailTextField *emailTextField;
@property (weak, nonatomic) IBOutlet QZBPasswordTextField *passwordTextField;

@end
