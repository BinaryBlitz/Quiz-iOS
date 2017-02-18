#import "UIImageView+QZBImagePickerCategory.h"

#import <UIImageView+AFNetworking.h>
#import "QZBCurrentUser.h"
#import <SVProgressHUD.h>
#import "QZBServerManager.h"


@implementation UIImageView (QZBImagePickerCategory)

-(void)loadDeafaultPicture {
    UIImage *image = [UIImage imageNamed:@"userpicStandart"];
  //  [self loadNewPic:image];
    
    UIImage *oldImg = [self.image copy];
    self.image = image;
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    [[QZBServerManager sharedManager] PATCHPlayerDeleteAvatarOnSuccess:^{
        [SVProgressHUD dismiss];
        
        [[QZBCurrentUser sharedInstance].user updateUserFromServer];
        self.image = image;

    } onFailure:^(NSError *error, NSInteger statusCode, QZBUserRegistrationProblem problem) {
        [SVProgressHUD showErrorWithStatus:@"Не удалось обновить аватар"];
        self.image = oldImg;
    }];
    
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
            
            [SVProgressHUD showErrorWithStatus:@"Не удалось обновить аватар"];
            self.image = oldImg;
        }];
    }
}

@end
