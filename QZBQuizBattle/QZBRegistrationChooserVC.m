//
//  QZBRegistrationChooserVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 16/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRegistrationChooserVC.h"
#import "QZBServerManager.h"
#import "QZBCurrentUser.h"
#import <SVProgressHUD/SVProgressHUD.h>

static NSString *const TOKEN_KEY = @"my_application_access_token";
static NSString *const NEXT_CONTROLLER_SEGUE_ID = @"START_WORK";
static NSArray *SCOPE = nil;

@interface QZBRegistrationChooserVC ()

@end

@implementation QZBRegistrationChooserVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];

    self.vkButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.enterButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.registrationButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;

    SCOPE = @[ VK_PER_FRIENDS, VK_PER_EMAIL, VK_PER_OFFLINE ];
    [super viewDidLoad];

    [VKSdk initializeWithDelegate:self andAppId:@"4795421"];
    if ([VKSdk wakeUpSession]) {
        [self startWorking];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (IBAction)authorize:(id)sender {
    //[VKSdk authorize:SCOPE revokeAccess:YES];

    [self performSegueWithIdentifier:@"enterUsernameSegue" sender:nil];
  //  [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
  //  [VKSdk authorize:SCOPE revokeAccess:YES];
}

- (void)startWorking {
    //[self performSegueWithIdentifier:NEXT_CONTROLLER_SEGUE_ID sender:self];

    // NSString *curentUserId =[[VKSdk getAccessToken] userId];

    NSLog(@"all good %@", [[VKSdk getAccessToken] userId]);
    //    VKRequest * req = [[VKApi users] get];
    //
    //    [req executeWithResultBlock:^(VKResponse *response) {
    //        NSLog(@"user: %@", response.json);
    //        NSLog(TOKEN_KEY);
    //    } errorBlock:^(NSError *error) {
    //
    //    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([[QZBCurrentUser sharedInstance] checkUser]) {
        NSLog(@"exist");
        [self dismissViewControllerAnimated:YES
                                 completion:^{

                                 }];
        //[self performSegueWithIdentifier:@"userExist" sender:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
    VKCaptchaViewController *vc = [VKCaptchaViewController captchaControllerWithError:captchaError];
    [vc presentIn:self];
}

- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken {
    [self authorize:nil];
}

- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken {
    NSLog(@"vk %@ %@", newToken.accessToken, newToken.expiresIn);

    [[QZBServerManager sharedManager] POSTAuthWithVKToken:newToken.accessToken
        onSuccess:^(QZBUser *user) {

            [[QZBCurrentUser sharedInstance] setUser:user];

            // [weakSelf performSegueWithIdentifier:@"LoginIsOK" sender:nil];

            [SVProgressHUD dismiss];

            [self dismissViewControllerAnimated:YES
                                     completion:^{

                                     }];

        }
        onFailure:^(NSError *error, NSInteger statusCode){
            [SVProgressHUD showErrorWithStatus:@"Проверьте подключение к интернету"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });

        }];

    [self startWorking];
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)vkSdkAcceptedUserToken:(VKAccessToken *)token {
    [self startWorking];
}
- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError {
    //[[[UIAlertView alloc] initWithTitle:nil message:@"Access denied" delegate:nil
    //cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];

    [SVProgressHUD dismiss];

    NSLog(@"deny");
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before
navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

//  NSLog(@"%@",segue);
}*/

@end
