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
#import "QZBFriendRequestManager.h"

@interface QZBMainTBC ()

@end

@implementation QZBMainTBC

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

    [self setSelectedIndex:2];
    self.tabBar.translucent = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBadges)
                                                 name:QZBFriendRequestUpdated object:nil];
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
        [[QZBFriendRequestManager sharedInstance] updateRequests];

        [self setSelectedIndex:2];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - support methods

-(void)updateBadges{
    
    UITabBarItem *it = self.tabBar.items[userBar];
    NSUInteger count = [QZBFriendRequestManager sharedInstance].incoming.count;
    if(count>0){
    
        it.badgeValue = [NSString stringWithFormat:@"%ld", (unsigned long)count];
    }else{
        it.badgeValue = nil;
    }
}


@end
