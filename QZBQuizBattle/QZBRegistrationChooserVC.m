
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
#import "QZBRegistrationUsernameInput.h"

static NSString *const TOKEN_KEY = @"my_application_access_token";
static NSString *const NEXT_CONTROLLER_SEGUE_ID = @"START_WORK";
static NSArray *SCOPE = nil;

@interface QZBRegistrationChooserVC ()

@property (strong, nonatomic) QZBUser *user;

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
    [VKSdk authorize:SCOPE revokeAccess:YES];

    [VKSdk authorize:SCOPE revokeAccess:YES];
}

- (void)startWorking {
    // redo
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([[QZBCurrentUser sharedInstance] checkUser]) {
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
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];

    [[QZBServerManager sharedManager] POSTAuthWithVKToken:newToken.accessToken
        onSuccess:^(QZBUser *user) {

            if (user.isRegistred) {
                [[QZBCurrentUser sharedInstance] setUser:user];

                // [weakSelf performSegueWithIdentifier:@"LoginIsOK" sender:nil];

                [SVProgressHUD dismiss];

                [self dismissViewControllerAnimated:YES
                                         completion:^{

                                         }];
            } else {
                self.user = user;
                [self performSegueWithIdentifier:@"enterUsernameSegue" sender:nil];
            }

        }
        onFailure:^(NSError *error, NSInteger statusCode) {
            [SVProgressHUD showErrorWithStatus:@"Проверьте подключение к "
                                               @"интернету"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),
                           dispatch_get_main_queue(), ^{
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
    // cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];

    [SVProgressHUD dismiss];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before
// navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    if ([segue.identifier isEqualToString:@"enterUsernameSegue"]) {
        UINavigationController *navController = segue.destinationViewController;

        for (UIViewController *vc in navController.viewControllers) {
            if ([vc isKindOfClass:[QZBRegistrationUsernameInput class]]) {
                QZBRegistrationUsernameInput *destVC = (QZBRegistrationUsernameInput *)vc;
                [destVC setUSerWhithoutUsername:self.user];
                break;
            }
        }

        //[destVC setUSerWhithoutUsername:self.user];
    }
}

@end
