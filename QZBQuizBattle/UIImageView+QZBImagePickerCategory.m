//
//  UIImageView+QZBImagePickerCategory.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 11/07/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "UIImageView+QZBImagePickerCategory.h"

#import <UIImageView+AFNetworking.h>
#import "QZBCurrentUser.h"
#import <SVProgressHUD.h>
#import "QZBServerManager.h"

@implementation UIImageView (QZBImagePickerCategory)

-(void)loadDeafaultPicture {
    UIImage *image = [UIImage imageNamed:@"userpicStandart"];
    [self loadNewPic:image];
    
}


-(void)loadNewPic:(UIImage *)image {
    if(image){
        
        UIImage *oldImg = [self.image copy];
      //  [[QZBCurrentUser sharedInstance].user deleteImage];
        self.image = image;
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        
      //  [self clearImageCacheForURL:[QZBCurrentUser sharedInstance].user.imageURL];
        //self.userPicImageView.image = nil;
        [[QZBServerManager sharedManager] PATCHPlayerWithNewAvatar:image onSuccess:^{
            
            [SVProgressHUD dismiss];
            
          //  [self clearImageCacheForURL:[QZBCurrentUser sharedInstance].user.imageURL];
            // self.userPicImageView.image = image;
            
            
            [[QZBCurrentUser sharedInstance].user updateUserFromServer];
            self.image = image;
            
            
        } onFailure:^(NSError *error, NSInteger statusCode, QZBUserRegistrationProblem problem) {
            
            [SVProgressHUD showErrorWithStatus:@"Не удалось обновить картинку"];
            self.image = oldImg;
        }];
    }
}

@end
