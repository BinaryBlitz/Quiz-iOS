//
//  QZBSettingsTVC.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 14/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QZBPasswordTextField.h"
@class QZBPasswordTextField;

@interface QZBSettingsTVC : UITableViewController
@property (weak, nonatomic) IBOutlet UIImageView *userPicImageView;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet QZBPasswordTextField *userNewPasswordTextField;
@property (weak, nonatomic) IBOutlet QZBPasswordTextField *userNewPasswordAgainTextField;

@end
