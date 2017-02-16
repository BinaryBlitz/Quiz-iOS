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
#import "UIColor+QZBProjectColors.h"

#import <SVProgressHUD.h>
#import <LayerKit/LayerKit.h>
#import "QZBLayerMessagerManager.h"

#import <SCLAlertView-Objective-C/SCLAlertView.h>


#import "UITabBarController+QZBMessagerCategory.h"


NSString *const QZBDoNotNeedShowMessagerNotifications = @"QZBDoNotNeedShowMessagerNotifications";
NSString *const QZBNeedShowMessagerNotifications = @"QZBNeedShowMessagerNotifications";

@interface QZBMainTBC ()

@property (assign, nonatomic) BOOL isAsked;

@property (strong, nonatomic) UIView *viewTest;

@end

@implementation QZBMainTBC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SVProgressHUD setForegroundColor:[UIColor brightRedColor]];

    [[QZBCurrentUser sharedInstance] checkUser];

    self.tabBar.tintColor = [UIColor whiteColor];
    self.tabBar.barTintColor = [UIColor blackColor];

    UIView *view = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.frame];
    view.backgroundColor = [UIColor lightBlueColor];
    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
    [currentWindow addSubview:view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(subscribeToMessages)
                                                 name:QZBNeedShowMessagerNotifications
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(unsubscribeFromMessages)
                                                 name:QZBDoNotNeedShowMessagerNotifications
                                               object:nil];
    
    
    
//    for (NSString* family in [UIFont familyNames])
//    {
//        NSLog(@"%@", family);
//        
//        for (NSString* name in [UIFont fontNamesForFamilyName: family])
//        {
//            NSLog(@"  %@", name);
//        }
//    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

  //  [self setSelectedIndex:2];
    self.tabBar.translucent = YES;
    
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

    if (![[QZBCurrentUser sharedInstance] checkUser]) {//redo
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
        [[QZBServerManager sharedManager] GETCategoriesOnSuccess:nil onFailure:nil];
        [[QZBFriendRequestManager sharedInstance] updateRequests];

     //   if(![QZBLayerMessagerManager sharedInstance].layerClient.authenticatedUser.userID){
        
    
    //    [QZBCurrentUser sharedInstance]
//        [[QZBLayerMessagerManager sharedInstance] connectWithCompletion:^(BOOL success, NSError *error) {
//            NSLog(@"done mof %@", error);
//        }];
   //     }
        
        [self subscribeToMessages];
        
        if(!self.isAsked){
            [self checkUpdate];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(subscribeToMessages)
                                                     name:QZBNeedShowMessagerNotifications
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(unsubscribeFromMessages)
                                                     name:QZBDoNotNeedShowMessagerNotifications
                                                   object:nil];

        
        //[self setSelectedIndex:2];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self unsubscribeFromMessages];
    
}

#pragma mark - support methods

-(void)updateBadges {
    
    UITabBarItem *it = self.tabBar.items[userBar];
    NSUInteger count = [QZBFriendRequestManager sharedInstance].incoming.count;
    
    NSUInteger messageCount = [[QZBLayerMessagerManager sharedInstance] unreadedCount];

    if(messageCount >0){
        count += messageCount;
    }
        
    if(count>0){
        it.badgeValue = [NSString stringWithFormat:@"%ld", (unsigned long)count];
    }else{
        it.badgeValue = nil;
    }
}


-(void)checkUpdate {
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
    
    NSString *version = infoDictionary[@"CFBundleShortVersionString"];
  //  NSString *build = infoDictionary[(NSString*)kCFBundleVersionKey];
    
    
    [[QZBServerManager sharedManager] GETCompareVersion:version
                                              onSuccess:^(QZBUpdateType updateType, NSString *message) {
        self.isAsked = YES;
        if(updateType != QZBUpdateTypeNone){
            [self showAlertVersionUpdateWithType:updateType message:message];
        }
    } onFailure:^(NSError *error, NSInteger statusCode) {
    
    }];
}

-(void)showAlertVersionUpdateWithType:(QZBUpdateType)type message:(NSString *)message {
    switch (type) {
        case QZBUpdateTypeMajor:
            [self showMajorUpdateWithMessage:message];
            break;
        case QZBUpdateTypeMinor:
            [self showMinorUpdateWithMessage:message];
            break;
        case QZBUpdateTypeBugfix:
            [self showBugFixWithMessage:message];
            break;
        default:
            break;
    }
}

-(void)showMajorUpdateWithMessage:(NSString *)message {
    
    [self showWithCompletionButton:nil message:message];
    
    
}

-(void)showMinorUpdateWithMessage:(NSString *)message {
    [self showWithCompletionButton:@"Отмена" message:message];
}

-(void)showBugFixWithMessage:(NSString *)message {
    
}

-(void)showWithCompletionButton:(NSString *)buttonTitle message:(NSString *)message{
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.backgroundType = Blur;
    alert.showAnimationType = FadeIn;
    
    NSString *title = [NSString stringWithFormat:@"Вышло обновление"];
    NSString *subTitle = [NSString
                          stringWithFormat:@"Вым необходимо обновить программу!"];
    if(message) {
        NSString *messageStringToAppend = [NSString stringWithFormat:@"Сообщение: %@",message];
        subTitle = [subTitle stringByAppendingString:messageStringToAppend];
    }
    
    [alert addButton:@"Обновить" actionBlock:^{
        NSString *iTunesLink = [NSString stringWithFormat:@"itms://itunes.apple.com/us/app/apple-store/id%@?mt=8", QZBiTunesIdentifier];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
    }];
    
    
    [alert showInfo:self
              title:title subTitle:subTitle
   closeButtonTitle:buttonTitle duration:0.0f];

}

@end
