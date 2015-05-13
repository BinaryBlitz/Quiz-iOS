//
//  QZBMainTBC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 30/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBMainTBC.h"
#import "QZBCurrentUser.h"
#import "QZBRegistrationChooserVC.h"
#import "UIColor+QZBProjectColors.h"
#import "QZBAchievementManager.h"
#import "QZBServerManager.h"
#import "QZBQuizTopicIAPHelper.h"
#import "QZBStoreListTVC.h"

@interface QZBMainTBC ()

@end

@implementation QZBMainTBC

//-(void)

- (void)viewDidLoad {
    [super viewDidLoad];

    [[QZBCurrentUser sharedInstance] checkUser];

    self.tabBar.tintColor = [UIColor whiteColor];
    self.tabBar.barTintColor = [UIColor blackColor];

    UIView *view = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.frame];
    view.backgroundColor = [UIColor lightBlueColor];
    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
    [currentWindow addSubview:view];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //   UIView *backgrView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]
    //   bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    //   backgrView.backgroundColor = [UIColor blackColor];
    //    backgrView.alpha = 1.0;
    //   [[[[UIApplication sharedApplication] delegate] window] addSubview:backgrView];
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1* NSEC_PER_SEC)),
    //    dispatch_get_main_queue(), ^{
    //        [backgrView removeFromSuperview];
    //    });

    [self setSelectedIndex:2];
    self.tabBar.translucent = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (![[QZBCurrentUser sharedInstance] checkUser]) {
        UIView *backgrView = [[UIView alloc]
            initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width,
                                     [[UIScreen mainScreen] bounds].size.height)];
        backgrView.backgroundColor = [UIColor blackColor];
        backgrView.alpha = 1.0;

        QZBRegistrationChooserVC *destination =
            [self.storyboard instantiateViewControllerWithIdentifier:@"registrationVC"];
        [self.view addSubview:backgrView];

        [self presentViewController:destination
                           animated:NO
                         completion:^{
                             [UIView animateWithDuration:0.5
                                 animations:^{
                                     backgrView.alpha = 0.0;
                                 }
                                 completion:^(BOOL finished) {
                                     [backgrView removeFromSuperview];
                                 }];
                         }];

        //[self performSegueWithIdentifier:@"showRegistrationScreen" sender:nil];
    } else {
        UINavigationController *navVC = self.viewControllers[4];

        QZBStoreListTVC *storeTVC = [navVC.viewControllers firstObject];

        [storeTVC reload];

        [storeTVC setNeedRelaod:YES];

        [[QZBAchievementManager sharedInstance] updateAchievements];
        [[QZBServerManager sharedManager] getСategoriesOnSuccess:nil onFailure:nil];

        [self setSelectedIndex:2];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before
navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
