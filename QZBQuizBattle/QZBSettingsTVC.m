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
#import <TSMessages/TSMessage.h>

@interface QZBSettingsTVC () <UIActionSheetDelegate,
                              DBCameraViewControllerDelegate,
                              UITextFieldDelegate>
@end
@implementation QZBSettingsTVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [TSMessage setDefaultViewController:self.navigationController];

    self.userPicImageView.image = [QZBCurrentUser sharedInstance].user.userPic;
    NSLog(@"userpic %@", [QZBCurrentUser sharedInstance].user.userPic);

    self.userNameTextField.text = [QZBCurrentUser sharedInstance].user.name;

    self.userNewPasswordTextField.delegate = self;
    self.userNewPasswordAgainTextField.delegate = self;
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
        if ([tf validate]) {
            [self.userNewPasswordAgainTextField becomeFirstResponder];
            return YES;
        } else {
            [TSMessage showNotificationWithTitle:
                           @"Пароль должен быть длинее 5 символов"
                                            type:TSMessageNotificationTypeWarning];
        }

    } else if ([tf isEqual:self.userNewPasswordAgainTextField]){
        if ([tf validate]) {
            if ([tf.text isEqualToString:self.userNewPasswordTextField.text]) {
                [self patchPassword];
                return YES;
            }else{
                [TSMessage showNotificationWithTitle:@"Пароли должны совпадать"
                                                type:TSMessageNotificationTypeWarning];
            }
            
        }else if(![self.userNewPasswordTextField validate]){
            
            [TSMessage showNotificationWithTitle:@"Введите пароль"
                                            type:TSMessageNotificationTypeWarning];
            
            self.userNewPasswordAgainTextField.text = @"";
            
            [self.userNewPasswordTextField becomeFirstResponder];
            
        } else {
          
        }
    }

    [tf shakeView];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"%ld", buttonIndex);

    if (buttonIndex == 0) {
        [self openLibrary];
    }

    if (buttonIndex == 1) {
        //[self performSegueWithIdentifier:@"showCamera" sender:nil];
        [self openCamera];
    }
}

- (IBAction)updatePasswordAction:(id)sender {
    
    
    
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
        onFailure:^(NSError *error, NSInteger statusCode){

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
    NSLog(@"delegate work %@", image);
    self.userPicImageView.image = image;
    [[QZBCurrentUser sharedInstance].user setUserPic:image];

    [cameraViewController restoreFullScreenMode];
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissCamera:(id)cameraViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
    [cameraViewController restoreFullScreenMode];
}
@end
