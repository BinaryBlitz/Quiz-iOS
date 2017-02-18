
#import "QZBRegistrationChooserVC.h"
#import "QZBServerManager.h"
#import "QZBCurrentUser.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "QZBRegistrationUsernameInput.h"

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

  SCOPE = @[@"friends", @"email", @"offline"];

  [[VKSdk initializeWithAppId:@"4795421"] registerDelegate:self];

  [VKSdk wakeUpSession:SCOPE completeBlock:^(VKAuthorizationState state, NSError *error) {
    [self startWorking];
  }];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [SVProgressHUD dismiss];
}

- (IBAction)authorize:(id)sender {
  NSLog(@"LALKA0");
  [VKSdk authorize:SCOPE];
}

// TODO: Redo
- (void)startWorking {
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  // TODO: возможно старый код, проверить
  if ([[QZBCurrentUser sharedInstance] checkUser]) {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
  }
}

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
  VKCaptchaViewController *vc = [VKCaptchaViewController captchaControllerWithError:captchaError];
  [vc presentIn:self];
}

- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken {
  [self authorize:nil];
}

- (void)vkSdkAccessAuthorizationFinishedWithResult:(VKAuthorizationResult *)result {

  [VKSdk wakeUpSession:SCOPE completeBlock:^(VKAuthorizationState state, NSError *error) {
    if (state == VKAuthorizationAuthorized) {
      // Authorized and ready to go

      [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];

      [[QZBServerManager sharedManager] POSTAuthWithVKToken:result.token.accessToken
                                                  onSuccess:^(QZBUser *user) {
                                                    if (user.isRegistred) {
                                                      [[QZBCurrentUser sharedInstance] setUser:user];
                                                      [SVProgressHUD dismiss];
                                                      [self dismissViewControllerAnimated:YES completion:^{
                                                      }];
                                                    } else {
                                                      self.user = user;
                                                      [self performSegueWithIdentifier:@"enterUsernameSegue" sender:nil];
                                                    }
                                                  }
                                                  onFailure:^(NSError *error, NSInteger statusCode) {
                                                    [SVProgressHUD showErrorWithStatus:@"Проверьте подключение к "
                                                        @"интернету"];
                                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (2 * NSEC_PER_SEC)),
                                                        dispatch_get_main_queue(), ^{
                                                          [SVProgressHUD dismiss];
                                                        });
                                                  }];

      [self startWorking];
    } else if (error) {
      // Some error happend, but you may try later
    }
  }];
}

- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken {
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
  [self presentViewController:controller animated:YES completion:nil];
}

- (void)vkSdkAcceptedUserToken:(VKAccessToken *)token {
  [self startWorking];
}

- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError {
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
        QZBRegistrationUsernameInput *destVC = (QZBRegistrationUsernameInput *) vc;
        [destVC setUSerWhithoutUsername:self.user];
        break;
      }
    }
  }
}

@end
