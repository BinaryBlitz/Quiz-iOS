//
//  QZBLoginWithEmailVCViewController.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 15/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRegisterAndLoginBaseVC.h"

@class QZBEmailTextField;
@class QZBPasswordTextField;

@interface QZBLoginWithEmailVC : QZBRegisterAndLoginBaseVC
@property (weak, nonatomic) IBOutlet QZBEmailTextField *emailTextField;
@property (weak, nonatomic) IBOutlet QZBPasswordTextField *passwordTextField;

@end
