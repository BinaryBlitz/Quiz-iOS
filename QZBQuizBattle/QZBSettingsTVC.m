//
//  QZBSettingsTVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 14/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBSettingsTVC.h"
#import "DBCameraViewController.h"
#import "DBCameraContainerViewController.h"
#import <DBCamera/DBCameraLibraryViewController.h>
#import <DBCamera/DBCameraSegueViewController.h>
#import "QZBCurrentUser.h"
#import "QZBUser.h"
#import "UIView+QZBShakeExtension.h"
#import "QZBRegistrationAndLoginTextFieldBase.h"
#import "QZBServerManager.h"
#import "QZBPasswordTextField.h"
#import "QZBUserNameTextField.h"
#import <TSMessages/TSMessage.h>
#import "UIImageView+AFNetworking.h"
#import "UIButton+QZBButtonCategory.h"
#import "UIViewController+QZBValidateCategory.h"
#import <JSQSystemSoundPlayer.h>



@interface QZBSettingsTVC () <UIActionSheetDelegate,
                              DBCameraViewControllerDelegate,
                              UITextFieldDelegate>
@end
@implementation QZBSettingsTVC

-(void)viewDidLoad{
    [super viewDidLoad];
    [self.middleCell addDropShadowsForView];
    [self.exitCell addDropShadowsForView];
    [self.soundCell addDropShadowsForView];
    
}
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
    
    [TSMessage setDefaultViewController:self.navigationController];

   // self.userPicImageView.image = [QZBCurrentUser sharedInstance].user.userPic;
    if([QZBCurrentUser sharedInstance].user.imageURL){
        [self.userPicImageView setImageWithURL:[QZBCurrentUser sharedInstance].user.imageURL];
    }else{
        [self.userPicImageView setImage:[UIImage imageNamed:@"userpicStandart"]];
    }
    self.userNameTextField.text = [QZBCurrentUser sharedInstance].user.name;
    
    self.nameTextFieldBackGroundView.layer.borderWidth = 1.0;
    self.nameTextFieldBackGroundView.layer.borderColor =[UIColor colorWithWhite:200.0/255.0 alpha:1.0].CGColor;
    

    self.userNewPasswordTextField.delegate = self;
    self.userNewPasswordAgainTextField.delegate = self;
    self.userNameTextField.delegate = self;
    
    
    NSString *renewPasswordText = self.renewPasswordButton.currentTitle;
    NSString *renewNameText = self.renewNameButton.currentTitle;
    
    [self.renewPasswordButton configButtonWithRoundedBorders];
    [self.renewNameButton configButtonWithRoundedBorders];
    [self.renewPasswordButton setTitle:renewPasswordText forState:UIControlStateNormal];
    [self.renewNameButton setTitle:renewNameText forState:UIControlStateNormal];
    
    self.renewNameButton.enabled = YES;
    self.renewPasswordButton.enabled = YES;
    
    self.tableView.backgroundColor = [UIColor colorWithWhite:250.0/255.0 alpha:1.0];
    
    self.soundSwitcher.on = [JSQSystemSoundPlayer sharedPlayer].on;
    
    
    
   // [self.topCell addShadows];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[JSQSystemSoundPlayer sharedPlayer] toggleSoundPlayerOn:self.soundSwitcher.on];
}


- (IBAction)changePicture:(UIButton *)sender {
    UIActionSheet *actSheet =
        [[UIActionSheet alloc] initWithTitle:@"Изменить аватар"
                                    delegate:self
                           cancelButtonTitle:@"Отменить"
                      destructiveButtonTitle:nil
                           otherButtonTitles:@"Выбрать из галереии",
                                             @"Сфотографировать", nil];

    [actSheet showInView:self.view];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    QZBRegistrationAndLoginTextFieldBase *tf = (QZBRegistrationAndLoginTextFieldBase *)textField;

    if ([tf isEqual:self.userNewPasswordTextField]) {
        if ([self checkFirstPassword]) {
            [self.userNewPasswordAgainTextField becomeFirstResponder];
            
            return YES;
        }
    } else if ([tf isEqual:self.userNewPasswordAgainTextField]) {
        if ([self checkPasswords]) {
            [self patchPassword];
            
            return YES;
        }
    } else if ([tf isEqual:self.userNameTextField]) {
        
        if ([self validateTextField:self.userNameTextField]) {
            [self updateUserName];

            return YES;
        }
    }

    return NO;
}

- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string {
    if ([textField isEqual:self.userNameTextField]) {
        NSString *res = [textField.text stringByAppendingString:string];
        if ([res length] > 20) {
            return NO;
        }
    }

    return YES;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (buttonIndex == 0) {
        [self openLibrary];
    }

    if (buttonIndex == 1) {
        //[self performSegueWithIdentifier:@"showCamera" sender:nil];
        [self openCamera];
    }
}

- (BOOL)checkPasswords {
    return [self checkFirstPassword] && [self checkSecondPassword];
}

- (BOOL)checkFirstPassword {
//    if (![self.userNewPasswordTextField validate]) {
//        
//        
//        [self.userNewPasswordTextField becomeFirstResponder];
//        [TSMessage showNotificationWithTitle:@"Пароль должен быть длинее 5 "
//                   @"символов" type:TSMessageNotificationTypeWarning];
//
//        self.userNewPasswordAgainTextField.text = @"";
//
//        [self.userNewPasswordTextField shakeView];
//
//        return NO;
//    } else {
//        return YES;
//    }
    
    return [self validateTextField:self.userNewPasswordTextField];
}

- (BOOL)checkSecondPassword {
    if (![self.userNewPasswordTextField.text
            isEqualToString:self.userNewPasswordAgainTextField.text]) {
        [TSMessage showNotificationWithTitle:@"Пароли должны совпадать"
                                        type:TSMessageNotificationTypeWarning];

        [self.userNewPasswordAgainTextField becomeFirstResponder];
        [self.userNewPasswordAgainTextField shakeView];
        return NO;

    } else {
        return YES;
    }
}

- (IBAction)updatePasswordAction:(id)sender {
    if ([self checkPasswords]) {
        [self patchPassword];
    }
}
- (IBAction)updateNameAction:(id)sender {
    if([self validateTextField:self.userNameTextField]){
        [self updateUserName];
    }
    
}

- (void)patchPassword {
    [[QZBServerManager sharedManager]
        PATCHPlayerWithNewPassword:self.userNewPasswordAgainTextField.text
        onSuccess:^(QZBUser *user) {

            [TSMessage showNotificationWithTitle:@"Пароль обновлен"
                                            type:TSMessageNotificationTypeSuccess];
            self.userNewPasswordAgainTextField.text = @"";
            self.userNewPasswordTextField.text = @"";
        }
        onFailure:^(NSError *error, NSInteger statusCode,QZBUserRegistrationProblem problem) {

            [TSMessage showNotificationWithTitle:@"Пароль не обновлен"
                                            type:TSMessageNotificationTypeWarning];

        }];
}

//- (BOOL)checkUserName {
//    if (![self.userNameTextField validate]) {
//        [TSMessage
//            showNotificationWithTitle:@"Имя должно быть длинее 1 символа"
//                                 type:TSMessageNotificationTypeWarning];
//        return NO;
//    } else {
//        return YES;
//    }
//}

- (void)updateUserName {
    NSString *newName = [self.userNameTextField.text copy];

    [[QZBServerManager sharedManager] PATCHPlayerWithNewUserName:newName
        onSuccess:^{
            [TSMessage showNotificationWithTitle:@"Имя обновлено"
                                            type:TSMessageNotificationTypeSuccess];
            [[QZBCurrentUser sharedInstance].user setUserName:newName];

        }
        onFailure:^(NSError *error, NSInteger statusCode,QZBUserRegistrationProblem problem) {
            
            if(problem == QZBUserNameProblem){
                [TSMessage
                 showNotificationWithTitle:@"Это имя уже занято"
                 type:TSMessageNotificationTypeWarning];

            }else{
                [TSMessage
                 showNotificationWithTitle:@"Имя не обновлено, проверьте "
                 @"интернет-соединение"
                 type:TSMessageNotificationTypeWarning];
            }
           
        }];
}

- (void)openCamera {
    DBCameraViewController *cameraController = [DBCameraViewController initWithDelegate:self];

    [cameraController setForceQuadCrop:YES];

    DBCameraContainerViewController *container =
        [[DBCameraContainerViewController alloc] initWithDelegate:self];
    [container setCameraViewController:cameraController];
    [container setFullScreenMode];

    UINavigationController *nav =
        [[UINavigationController alloc] initWithRootViewController:container];
    [nav setNavigationBarHidden:YES];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)openLibrary {
    DBCameraLibraryViewController *vc = [[DBCameraLibraryViewController alloc] init];
    [vc setDelegate:self];       // DBCameraLibraryViewController must have a
                                 // DBCameraViewControllerDelegate object
    [vc setForceQuadCrop:YES];   // Optional
    [vc setUseCameraSegue:YES];  // Optional
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [nav setNavigationBarHidden:YES];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - DBCameraViewControllerDelegate

- (void)camera:(id)cameraViewController
    didFinishWithImage:(UIImage *)image
          withMetadata:(NSDictionary *)metadata {
    
    
    [[QZBServerManager sharedManager] PATCHPlayerWithNewAvatar:image onSuccess:^{

        
        [self.userPicImageView clearImageCacheForURL:[QZBCurrentUser sharedInstance].user.imageURL];
        self.userPicImageView.image = image;
        
        
        [[QZBCurrentUser sharedInstance].user updateUserFromServer];
        
        
        
    } onFailure:^(NSError *error, NSInteger statusCode, QZBUserRegistrationProblem problem) {

    }];
    
   // self.userPicImageView.image = image;
    //[[QZBCurrentUser sharedInstance].user setUserPic:image];

    [cameraViewController restoreFullScreenMode];
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissCamera:(id)cameraViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
    [cameraViewController restoreFullScreenMode];
}

#pragma mark - actions

- (IBAction)logOutAction:(UIButton *)sender {
    [[QZBCurrentUser sharedInstance] userLogOut];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    
        [self.navigationController popToRootViewControllerAnimated:NO];
    });
    
   // [self.navigationController popToRootViewControllerAnimated:NO];

    [self performSegueWithIdentifier:@"logOutFromSettings" sender:nil];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
