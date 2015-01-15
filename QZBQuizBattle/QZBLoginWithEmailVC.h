//
//  QZBLoginWithEmailVCViewController.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 15/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRegisterAndLoginBaseVC.h"

@interface QZBLoginWithEmailVC : QZBRegisterAndLoginBaseVC
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end
