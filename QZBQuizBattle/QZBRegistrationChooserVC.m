//
//  QZBRegistrationChooserVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 16/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRegistrationChooserVC.h"
#import "QZBCurrentUser.h"

static NSString *const TOKEN_KEY = @"my_application_access_token";
static NSString *const NEXT_CONTROLLER_SEGUE_ID = @"START_WORK";
static NSArray  * SCOPE = nil;


@interface QZBRegistrationChooserVC ()

@end

@implementation QZBRegistrationChooserVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SCOPE = @[VK_PER_FRIENDS, VK_PER_EMAIL];
    [super viewDidLoad];
    
    [VKSdk initializeWithDelegate:self andAppId:@"4793505"];
    if ([VKSdk wakeUpSession])
    {
        [self startWorking];
    }

}

- (IBAction)authorize:(id)sender {
    //[VKSdk authorize:SCOPE revokeAccess:YES];
    
    [VKSdk authorize:SCOPE revokeAccess:YES];
}


- (void)startWorking {
    //[self performSegueWithIdentifier:NEXT_CONTROLLER_SEGUE_ID sender:self];
    
    //NSString *curentUserId =[[VKSdk getAccessToken] userId];
    
    NSLog(@"all good %@" ,[[VKSdk getAccessToken] userId]);
    VKRequest * req = [[VKApi users] get];
    
    [req executeWithResultBlock:^(VKResponse *response) {
        NSLog(@"user: %@", response.json);
    } errorBlock:^(NSError *error) {
        
    }];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([[QZBCurrentUser sharedInstance] checkUser]) {
        NSLog(@"exist");
        [self performSegueWithIdentifier:@"userExist" sender:nil];
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
    [self startWorking];
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)vkSdkAcceptedUserToken:(VKAccessToken *)token {
    [self startWorking];
}
- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError {
    [[[UIAlertView alloc] initWithTitle:nil message:@"Access denied" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    
    NSLog(@"deny");
}


#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

//  NSLog(@"%@",segue);
}*/

@end
