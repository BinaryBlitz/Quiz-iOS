//
//  QZBImageViewerVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 10/07/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBImageViewerVC.h"
#import <UIImageView+AFNetworking.h>
#import "QZBCurrentUser.h"
//#import <SVProgressHUD.h>
//#import "QZBServerManager.h"
#import "UIImageView+QZBImagePickerCategory.h"

@interface QZBImageViewerVC()

@property(strong, nonatomic) id<QZBUserProtocol> user;

@end

@implementation QZBImageViewerVC

-(void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(self.user.imageURL){
        
        [self.userPicImageView setImageWithURL:self.user.imageURL];
    } else {
        [self.userPicImageView setImage:[UIImage imageNamed:@"userpicStandart"]];
    }

}

-(void)configureWithUser:(id<QZBUserProtocol>)user {
    
    self.user = user;

//    if(self.user.imageURL){
//        
//            [self.userPicImageView setImageWithURL:self.user.imageURL
//                                  placeholderImage:[UIImage imageNamed:@"userpicStandart"]];
//            } else {
//                [self.userPicImageView setImage:[UIImage imageNamed:@"userpicStandart"]];
//            }

    
    if([[QZBCurrentUser sharedInstance].user.userID isEqualToNumber:user.userID]){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                                       initWithTitle:@"Изменить"
                                                                       style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(showChoose)];
        
    }
}
#pragma  mark - action sheet
-(void)showChoose{
   // [self selectPhoto:nil];
    UIActionSheet *actSheet =
    [[UIActionSheet alloc] initWithTitle:@"Изменить аватар"
                                delegate:self
                       cancelButtonTitle:@"Отменить"
                  destructiveButtonTitle:nil
                       otherButtonTitles:@"Выбрать из галереии",
     @"Сфотографировать", @"Удалить фотографию", nil];
    
    [actSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary]) {
            [self selectPhoto:nil];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Нет доступа к фотогалерее"
                                        message:@"Включите доступ к фотогалерее в настройках приложения"
                                       delegate:nil
                              cancelButtonTitle:@"Ок"
                              otherButtonTitles: nil] show];
        }
    }else if (buttonIndex == 1) {
        //[self performSegueWithIdentifier:@"showCamera" sender:nil];
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
            [self takePhoto:nil];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Нет доступа к камере" message:@"Включите доступ к камере в настройках приложения" delegate:nil cancelButtonTitle:@"Ок" otherButtonTitles: nil] show];
        }
    }else if (buttonIndex == 2) {
        [self.userPicImageView loadDeafaultPicture];
    }
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


#pragma mark - image picker


- (IBAction)takePhoto:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}


- (IBAction)selectPhoto:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
    
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    //self.userPicImageView.image = chosenImage;
    
    [self.userPicImageView loadNewPic:chosenImage];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}


//-(void)loadDeafaultPicture {
//    UIImage *image = [UIImage imageNamed:@"userpicStandart"];
//    [self loadNewPic:image];
//    
//}
//
//
//-(void)loadNewPic:(UIImage *)image {
//    if(image){
//        
//        UIImage *oldImg = [self.userPicImageView.image copy];
//        [[QZBCurrentUser sharedInstance].user deleteImage];
//        self.userPicImageView.image = image;
//        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
//        
//        [self.userPicImageView clearImageCacheForURL:[QZBCurrentUser sharedInstance].user.imageURL];
//        //self.userPicImageView.image = nil;
//        [[QZBServerManager sharedManager] PATCHPlayerWithNewAvatar:image onSuccess:^{
//            
//            [SVProgressHUD dismiss];
//            
//            [self.userPicImageView clearImageCacheForURL:[QZBCurrentUser
//                                                          sharedInstance].user.imageURL];
//            // self.userPicImageView.image = image;
//            
//            
//            [[QZBCurrentUser sharedInstance].user updateUserFromServer];
//            self.userPicImageView.image = image;
//            
//            
//        } onFailure:^(NSError *error, NSInteger statusCode, QZBUserRegistrationProblem problem) {
//            
//            [SVProgressHUD showErrorWithStatus:@"Не удалось обновить картинку"];
//            self.userPicImageView.image = oldImg;
//        }];
//    }
//}


@end