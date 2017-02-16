//
//  QZBRegistrationUsernameInput.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 12/04/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QZBRegisterAndLoginBaseVC.h"

@class QZBUserNameTextField;

@interface QZBRegistrationUsernameInput : QZBRegisterAndLoginBaseVC

@property (weak, nonatomic) IBOutlet QZBUserNameTextField *usernameTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSuperViewConstraint;

-(void)setUSerWhithoutUsername:(QZBUser *)user;

@end
