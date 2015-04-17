//
//  QZBEndSessionControllerViewController.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 21/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import "QZBEndSessionControllerViewController.h"
#import "QZBGameTopic.h"
#import "QZBProgressViewController.h"
#import "QZBTopicChooserControllerViewController.h"
#import "QZBCategoryChooserVC.h"
#import "QZBSessionManager.h"
#import "UIViewController+QZBControllerCategory.h"
//#import "UIViewController+QZBControllerCategory.h"
#import <UAProgressView.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <JSBadgeView.h>
#import "NSObject+QZBSpecialCategory.h"


@interface QZBEndSessionControllerViewController ()

@property (assign, nonatomic) NSInteger currentLevel;
//@property(assign, nonatomic) NSInteger beginLevel;
@property (assign, nonatomic) NSInteger resultLevel;
@property (assign, nonatomic) float resultProgress;

@property (strong, nonatomic) JSBadgeView *userBV;
@property (strong, nonatomic) JSBadgeView *opponentBV;
@property (assign, nonatomic) BOOL isShowed;

@end

@implementation QZBEndSessionControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = nil;

    [self.navigationItem setHidesBackButton:YES animated:NO];

    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    self.tabBarController.tabBar.hidden = NO;

    [self.tabBarController setHidesBottomBarWhenPushed:NO];

    self.circularProgress.lineWidth = 10;
    self.circularOldProgress.lineWidth = 11;
    self.circularProgress.borderWidth = 0;
    self.circularOldProgress.borderWidth = 0;
    
    self.circularOldProgress.fillOnTouch = NO;
    self.circularProgress.fillOnTouch = NO;
    
    self.circularOldProgress.tintColor = [UIColor lightBlueColor];
    self.circularProgress.tintColor = [UIColor lightGreenColor];
    [self setResultsOfSession];

    //    if(![QZBSessionManager sessionManager].isOfflineChallenge){
    //        self.title = [QZBSessionManager sessionManager].sessionResult;
    //    }

    //[[self navigationController] setNavigationBarHidden:YES animated:NO];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.tabBarController.tabBar.hidden = NO;

    [self.tabBarController setHidesBottomBarWhenPushed:NO];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(achievementGet:)
                                                 name:@"QZBAchievmentGet"
                                               object:nil];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.tabBarController.tabBar.hidden = NO;
}

- (void)movingProgress {
 
    NSInteger beginScore = [QZBSessionManager sessionManager].userBeginingScore;
    NSUInteger gettedScore = [QZBSessionManager sessionManager].firstUserScore;
    NSInteger multiplier = [QZBSessionManager sessionManager].multiplier;

    NSInteger newScore = beginScore + gettedScore * multiplier;

    NSInteger beginLevel = 0;
    float beginProgress = 0.0;
    NSInteger resultLevel = 0;
    float resultProgress = 0.0;

    [NSObject calculateLevel:&beginLevel levelProgress:&beginProgress fromScore:beginScore];

    self.circularProgress.centralView = [self labelForNum:beginLevel inView:self.circularProgress];

    [self.circularProgress setProgress:beginProgress animated:NO];

    [NSObject calculateLevel:&resultLevel levelProgress:&resultProgress fromScore:newScore];

    self.resultLevel = resultLevel;
    self.currentLevel = beginLevel;
    self.resultProgress = resultProgress;

    self.circularProgress.animationDuration = 2.0;
    
    self.circularOldProgress.progress = beginProgress;
    
    [self turningCircularView];

}

- (void)turningCircularView {
    self.circularProgress.centralView =
        [self labelForNum:self.currentLevel inView:self.circularProgress];

    if (self.currentLevel == self.resultLevel) {
        [self.circularProgress setProgress:self.resultProgress animated:YES];
    }

    if (self.currentLevel < self.resultLevel) {
        [self.circularProgress setProgress:0.9999 animated:YES];
        CFTimeInterval time = self.circularProgress.animationDuration + 0.1;

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{

                           [self.circularOldProgress removeFromSuperview];
                           self.circularProgress.progress = 0.0;
                           self.currentLevel++;
                           [self turningCircularView];

                       });
     }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popToRootViewControllerAnimated:NO];
}
- (void)achievementGet:(NSNotification *)note {
    [self showAlertAboutAchievmentWithDict:note.object];
}


- (IBAction)rematchAction:(UIButton *)sender {
    [self moveToVCWithClass:[QZBProgressViewController class]];
}

- (IBAction)ChooseTopicAction:(UIButton *)sender {
    [self moveToVCWithClass:[QZBTopicChooserControllerViewController class]];
    //[self.navigationController popToRootViewControllerAnimated:YES];
}
- (IBAction)chooseCategoryAction:(id)sender {
    [self moveToVCWithClass:[QZBCategoryChooserVC class]];
}

- (void)moveToVCWithClass:(__unsafe_unretained Class)VCclass {
    NSArray *controllers = self.navigationController.viewControllers;

    UIViewController *destinationVC;

    for (UIViewController *controller in controllers) {
        if ([controller isKindOfClass:VCclass]) {
            NSLog(@"%@", [controller class]);

            destinationVC = controller;
            break;
        }
    }
    if (!destinationVC) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.navigationController popToViewController:destinationVC animated:YES];
    }
}

- (void)setResultsOfSession {
    self.title = [QZBSessionManager sessionManager].topic.name;

    self.firstUserScore.text = @"";
    self.opponentScore.text = @"";

    self.userNameLabel.text = [QZBSessionManager sessionManager].firstUserName;

    if ([QZBSessionManager sessionManager].opponentUserName) {
        self.opponentNameLabel.text = [QZBSessionManager sessionManager].opponentUserName;
    }

    if ([QZBSessionManager sessionManager].firstImageURL) {
        [self.userImage setImageWithURL:[QZBSessionManager sessionManager].firstImageURL];
    }else{
        [self.userImage setImage:[UIImage imageNamed:@"userpicStandart"]];
    }

    if ([QZBSessionManager sessionManager].opponentImageURL) {
        [self.opponentImage setImageWithURL:[QZBSessionManager sessionManager].opponentImageURL];
    }else{
        [self.opponentImage setImage:[UIImage imageNamed:@"userpicStandart"]];
    }

    self.userBV = [[JSBadgeView alloc] initWithParentView:self.firstUserScore
                                                alignment:JSBadgeViewAlignmentCenterLeft];
    self.opponentBV = [[JSBadgeView alloc] initWithParentView:self.opponentScore
                                                    alignment:JSBadgeViewAlignmentCenterRight];

    self.userBV.badgeTextFont = [UIFont systemFontOfSize:20];
    self.opponentBV.badgeTextFont = [UIFont systemFontOfSize:20];
    self.userBV.badgeBackgroundColor = [UIColor lightBlueColor];
    self.opponentBV.badgeBackgroundColor = [UIColor lightBlueColor];

    self.opponentBV.badgeText = [NSString
        stringWithFormat:@"%ld", (unsigned long)[QZBSessionManager sessionManager].secondUserScore];
    self.userBV.badgeText = [NSString
        stringWithFormat:@"%ld", (unsigned long)[QZBSessionManager sessionManager].firstUserScore];

    if (![QZBSessionManager sessionManager].isOfflineChallenge) {
        self.resultOfSessionLabel.text = [QZBSessionManager sessionManager].sessionResult;
    } else {
        self.resultOfSessionLabel.text = @"Ждем соперника";
    }

    NSInteger multiplier = [QZBSessionManager sessionManager].multiplier;
    NSInteger userScore = [QZBSessionManager sessionManager].firstUserScore;

    NSInteger resultScore = userScore * multiplier;

    self.resultScoreLabel.text = [NSString stringWithFormat:@"%ld", (long)resultScore];

    [self movingProgress];

    [[QZBSessionManager sessionManager] closeSession];
}

- (BOOL)hidesBottomBarWhenPushed {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
