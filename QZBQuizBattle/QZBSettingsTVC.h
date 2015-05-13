//
//  QZBSettingsTVC.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 14/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QZBPasswordTextField;
@class QZBUserNameTextField;

@interface QZBSettingsTVC : UITableViewController
@property (weak, nonatomic) IBOutlet UIImageView *userPicImageView;
@property (weak, nonatomic) IBOutlet QZBUserNameTextField *userNameTextField;
@property (weak, nonatomic) IBOutlet QZBPasswordTextField *userNewPasswordTextField;
@property (weak, nonatomic) IBOutlet QZBPasswordTextField *userNewPasswordAgainTextField;
@property (weak, nonatomic) IBOutlet UIButton *renewPasswordButton;
@property (weak, nonatomic) IBOutlet UIButton *renewNameButton;
@property (weak, nonatomic) IBOutlet UITableViewCell *middleCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *topCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *exitCell;
@property (weak, nonatomic) IBOutlet UIView *nameTextFieldBackGroundView;
@property (weak, nonatomic) IBOutlet UISwitch *soundSwitcher;
@property (weak, nonatomic) IBOutlet UITableViewCell *soundCell;

@end
