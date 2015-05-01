//
//  QZBEndGameVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 09/04/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBEndGameVC.h"
#import "QZBEndGameMainCell.h"
#import "QZBEndGamePointsCell.h"
#import "QZBEndGameResultScoreCell.h"
#import "QZBEndGameProgressCell.h"
#import "QZBSessionManager.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "UIViewController+QZBControllerCategory.h"
#import "QZBGameTopic.h"
#import <JSBadgeView.h>
#import "UIColor+QZBProjectColors.h"
#import "QZBCategory.h"
#import "QZBTopicChooserControllerViewController.h"
#import "QZBPlayerPersonalPageVC.h"
#import "QZBProgressViewController.h"
#import "QZBFriendsChallengeTVC.h"
#import "QZBUser.h"
#import "QZBAnotherUser.h"

#import "QZBChallengeDescriptionWithResults.h"

@interface QZBEndGameVC ()

@property (copy, nonatomic) NSString *firstUserName;
@property (copy, nonatomic) NSString *opponentUserName;
@property (assign, nonatomic) NSUInteger firstUserScore;
@property (assign, nonatomic) NSUInteger secondUserScore;
@property (copy, nonatomic) NSString *sessionResult;
@property (copy, nonatomic) NSURL *firstImageURL;
@property (copy, nonatomic) NSURL *opponentImageURL;
@property (strong, nonatomic) QZBGameTopic *topic;
@property (assign, nonatomic) NSInteger multiplier;
@property (assign, nonatomic) NSInteger beginScore;
@property (assign, nonatomic) NSInteger endScore;
@property (assign, nonatomic) BOOL progressShown;
@property (assign, nonatomic) BOOL cellInited;
@property (assign, nonatomic) BOOL isOfflineChallenge;
@property (assign, nonatomic) BOOL isChallenge;
@property (assign, nonatomic) BOOL isJustResult;
@property (assign, nonatomic) BOOL isMainInited;
@property (strong, nonatomic) id<QZBUserProtocol> opponent;
@property(strong, nonatomic) QZBChallengeDescriptionWithResults *challengeDescriptionWithResult;

@end

@implementation QZBEndGameVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];

    self.navigationItem.leftBarButtonItem = nil;

    [self.navigationItem setHidesBackButton:YES animated:NO];

    [[self navigationController] setNavigationBarHidden:NO animated:NO];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    if(!self.challengeDescriptionWithResult){
        [self initSessionResults];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;

    [self.tabBarController setHidesBottomBarWhenPushed:NO];

    [self.tableView layoutIfNeeded];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(achievementGet:)
                                                 name:@"QZBAchievmentGet"
                                               object:nil];

    QZBGameTopic *topic = self.topic;

    QZBCategory *category = [[QZBServerManager sharedManager] tryFindRelatedCategoryToTopic:topic];
    if (category) {
        NSURL *url = [NSURL URLWithString:category.background_url];
        NSURLRequest *imageRequest =
            [NSURLRequest requestWithURL:url
                             cachePolicy:NSURLRequestReturnCacheDataElseLoad
                         timeoutInterval:60];
        
        CGRect r = CGRectMake(0, 0,  CGRectGetWidth([UIScreen mainScreen].bounds),
                              16*CGRectGetWidth([UIScreen mainScreen].bounds)/9);
        
        UIImageView *iv = [[UIImageView alloc] initWithFrame:r];
        
        self.tableView.backgroundColor = [UIColor clearColor];

        [iv setImageWithURLRequest:imageRequest
                  placeholderImage:nil
                           success:nil
                           failure:nil];
        
        //  [self.view addSubview:iv];
        //  [self.view sendSubviewToBack:iv];
        
        //[self.view insertSubview:iv atIndex:0];
        
        self.tableView.backgroundView = iv;
        
    }
    // [self.tableView layoutIfNeeded];
}




- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.tabBarController.tabBar.hidden = NO;

    if(!self.isOfflineChallenge){
        [self animateLose];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initSessionResults {
    self.title = [QZBSessionManager sessionManager].topic.name;

    self.firstUserName = [QZBSessionManager sessionManager].firstUserName;

    if ([QZBSessionManager sessionManager].opponentUserName) {
        self.opponentUserName = [QZBSessionManager sessionManager].opponentUserName;
    }

    if ([QZBSessionManager sessionManager].firstImageURL) {
        self.firstImageURL = [QZBSessionManager sessionManager].firstImageURL;
    }

    if ([QZBSessionManager sessionManager].opponentImageURL) {
        self.opponentImageURL = [QZBSessionManager sessionManager].opponentImageURL;
    }

    self.firstUserScore = [QZBSessionManager sessionManager].firstUserScore;

    self.secondUserScore = [QZBSessionManager sessionManager].secondUserScore;

    self.isOfflineChallenge = [QZBSessionManager sessionManager].isOfflineChallenge;

    if (![QZBSessionManager sessionManager].isOfflineChallenge) {
        self.sessionResult = [QZBSessionManager sessionManager].sessionResult;
    } else {
        self.sessionResult = @"Ждем соперника";
    }

    self.topic = [QZBSessionManager sessionManager].topic;

    self.multiplier = [QZBSessionManager sessionManager].multiplier;

    self.beginScore = [QZBSessionManager sessionManager].userBeginingScore;

    self.endScore = self.beginScore + self.firstUserScore * self.multiplier;

    if ([QZBSessionManager sessionManager].isChallenge) {
        self.opponent = [QZBSessionManager sessionManager].opponent;
    } else {
        self.opponent = nil;
    }
    [[QZBSessionManager sessionManager] closeSession];
    

}

-(void)initWithChallengeResult:(QZBChallengeDescriptionWithResults *)challengeDescription{
    
    self.challengeDescriptionWithResult = challengeDescription;
    
    self.title = challengeDescription.topic.name;
    
    self.firstUserName = challengeDescription.firstUser.name;
    self.opponentUserName = challengeDescription.opponentUser.name;
    
    
    if (challengeDescription.firstUser.imageURL) {
        self.firstImageURL = challengeDescription.firstUser.imageURL;
    }
    
    if (challengeDescription.opponentUser.imageURL) {
        self.opponentImageURL = challengeDescription.opponentUser.imageURL;
    }
    
    self.firstUserScore = (NSUInteger)challengeDescription.firstResult;
    self.secondUserScore = (NSUInteger)challengeDescription.opponentResult;
    
    self.sessionResult = [self resultOfSession];
    
    self.multiplier = challengeDescription.multiplier;
    
    self.topic = challengeDescription.topic;
    
    self.beginScore = self.endScore = [challengeDescription.topic.points integerValue];
    
    self.opponent = challengeDescription.opponentUser;
    
    [[QZBServerManager sharedManager]DELETELobbiesWithID:challengeDescription.lobbyID onSuccess:^{
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
    }];
    
    
}

-(NSString *)resultOfSession{
    NSString *result = nil;
    
    if(self.firstUserScore>self.secondUserScore){
        result = @"Победа";
    }else if (self.firstUserScore< self.secondUserScore){
        result = @"Поражение";
    } else{
        result = @"Ничья";
    }
    return result;
}

- (void)achievementGet:(NSNotification *)note {
    [self showAlertAboutAchievmentWithDict:note.object];
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

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's
// reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source
// (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *mainCellIdentifier = @"endGameMainCell";
    static NSString *pointCellIdentifier = @"endGamePointsCell";
    static NSString *resultCellIdentifier = @"endGameResultPointsCell";
    static NSString *progressCellIdentifier = @"endGameProgressCell";
    

    UITableViewCell *cell = nil;
    if (indexPath.row == 0) {
        QZBEndGameMainCell *mainCell =
            [tableView dequeueReusableCellWithIdentifier:mainCellIdentifier];

        if(!self.isMainInited){
            self.isMainInited = YES;
            [self initMainCell:mainCell];
        }
    
        //[self initMainCell:mainCell];

        return mainCell;
    } else if (indexPath.row == 1) {
        QZBEndGamePointsCell *pointsCell =
            [tableView dequeueReusableCellWithIdentifier:pointCellIdentifier];
        [pointsCell setCentralLabelWithNimber:self.multiplier];
        [pointsCell setScore:self.firstUserScore];
        return pointsCell;
    } else if (indexPath.row == 3) {
        QZBEndGameResultScoreCell *resultScoreCell =
            [tableView dequeueReusableCellWithIdentifier:resultCellIdentifier];

        NSInteger result = self.firstUserScore * self.multiplier;
        [resultScoreCell setResultScore:result];
        return resultScoreCell;
    } else if (indexPath.row == 2) {
        QZBEndGameProgressCell *progressCell =
            [tableView dequeueReusableCellWithIdentifier:progressCellIdentifier];
        //[progressCell initCell];
        if (!self.cellInited) {
            self.cellInited = YES;
            [progressCell initCellWithBeginScore:self.beginScore];
        }

        return progressCell;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 360;
    } else if (indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3) {
        return 150;
    } else {
        return 100;
    }
}

//- (void)checkVisibilityOfCell:(MyCustomUITableViewCell *)cell inScrollView:(UIScrollView
//*)aScrollView {
//    CGRect cellRect = [aScrollView convertRect:cell.frame toView:aScrollView.superview];
//
//    if (CGRectContainsRect(aScrollView.frame, cellRect))
//        [cell notifyCompletelyVisible];
//    else
//        [cell notifyNotCompletelyVisible];
//}

- (BOOL)checkVisibilityOfCell:(UITableViewCell *)cell inScrollView:(UIScrollView *)scrollView {
    CGRect cellRect = [scrollView convertRect:cell.frame toView:scrollView.superview];
    return CGRectContainsRect(scrollView.frame, cellRect);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSArray *cells = self.tableView.visibleCells;

    for (UITableViewCell *cell in cells) {
        if ([cell isKindOfClass:[QZBEndGameProgressCell class]]) {
            if ([self checkVisibilityOfCell:cell inScrollView:scrollView]) {
                if (!self.progressShown) {
                    self.progressShown = YES;
                    QZBEndGameProgressCell *c = (QZBEndGameProgressCell *)cell;
                    [c moveProgressFromBeginScore:self.beginScore toEndScore:self.endScore];
                }
            }
        }
    }
}

#pragma mark - cell init

- (void)initMainCell:(QZBEndGameMainCell *)cell {
    [cell initCell];

    cell.userNameLabel.text = self.firstUserName;

    if (self.opponentUserName) {
        cell.opponentNameLabel.text = self.opponentUserName;
    }

    if (self.firstImageURL) {
        [cell.userImage setImageWithURL:self.firstImageURL];
    } else {
        [cell.userImage setImage:[UIImage imageNamed:@"userpicStandart"]];
    }

    if (self.opponentImageURL) {
        [cell.opponentImage setImageWithURL:self.opponentImageURL];
    } else {
        [cell.opponentImage setImage:[UIImage imageNamed:@"userpicStandart"]];
    }

    cell.opponentBV.badgeText =
        [NSString stringWithFormat:@"%ld", (unsigned long)self.secondUserScore];
    
    cell.userBV.badgeText = [NSString stringWithFormat:@"%ld", (unsigned long)self.firstUserScore];
    cell.resultOfSessionLabel.text = self.sessionResult;

    cell.playAgainButton.exclusiveTouch = YES;
    cell.chooseAnotherTopicButton.exclusiveTouch = YES;

    if (self.isOfflineChallenge) {
        [cell.playAgainButton setTitle:@"Выбрать другого соперника" forState:UIControlStateNormal];
    }
}

#pragma mark - actions

- (IBAction)playAgainAction:(UIButton *)sender {
    if (self.isOfflineChallenge) {
        [self moveToPlayerChooseVC];
        return;
    }

    NSMutableArray *controllers = [self.navigationController.viewControllers mutableCopy];

    UIViewController *destinationVC;

    for (UIViewController *controller in controllers) {
        if ([controller isKindOfClass:[QZBProgressViewController class]]) {
            destinationVC = controller;
            break;
        }
    }

//    QZBProgressViewController *progressVC =
//        [self.storyboard instantiateViewControllerWithIdentifier:@"QZBPreparingScreenIdentifier"];
//
//    [progressVC initSessionWithTopic:self.topic user:nil];
    if(!destinationVC && !self.opponent){
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
//    NSUInteger objectIndex =
//    [self.navigationController.viewControllers indexOfObject:destinationVC];
    
    QZBProgressViewController *progressVC = [self.storyboard
                                             instantiateViewControllerWithIdentifier:@"QZBPreparingScreenIdentifier"];
    
    [progressVC initSessionWithTopic:self.topic user:self.opponent];
    
    

    if (!destinationVC) {
        NSUInteger objectIndex =
        [self.navigationController.viewControllers indexOfObject:self];
        [controllers insertObject:progressVC atIndex:objectIndex];
        
    } else {
        NSUInteger objectIndex =
        [self.navigationController.viewControllers indexOfObject:destinationVC];
        [controllers replaceObjectAtIndex:objectIndex withObject:progressVC];
    }

    [self.navigationController setViewControllers:[NSArray arrayWithArray:controllers]];
    
    [self.navigationController popToViewController:progressVC animated:YES];
    
    
    // self.navigationController.viewControllers
}
- (IBAction)chooseAnotherTopic:(id)sender {
    NSEnumerator *controllers = [self.navigationController.viewControllers reverseObjectEnumerator];

    UIViewController *destinationVC;

    for (UIViewController *controller in controllers) {
        if ([controller isKindOfClass:[QZBTopicChooserControllerViewController class]] ||
            [controller isKindOfClass:[QZBPlayerPersonalPageVC class]]) {
            // NSLog(@"%@", [controller class]);

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

- (void)moveToPlayerChooseVC {
    if (self.isOfflineChallenge) {
        NSEnumerator *controllers =
            [self.navigationController.viewControllers reverseObjectEnumerator];

        UIViewController *destinationVC;

        for (UIViewController *controller in controllers) {
            if ([controller isKindOfClass:[QZBFriendsChallengeTVC class]] ||
                [controller isKindOfClass:[QZBPlayerPersonalPageVC class]]) {
                // NSLog(@"%@", [controller class]);

                destinationVC = controller;
                break;
            }
        }

        if (!destinationVC) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        } else {
            [self.navigationController popToViewController:destinationVC animated:YES];
        }

    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
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

- (void)animateLose {
    CGRect mainRect = [UIScreen mainScreen].bounds;

    CGRect rLeft = CGRectMake(0, -CGRectGetHeight(mainRect) * 1.4,
                              0.6 * CGRectGetWidth(mainRect), 1.4 * CGRectGetHeight(mainRect));

    CGRect rRight = CGRectMake(0.25 * CGRectGetWidth(mainRect), CGRectGetHeight(mainRect),
                               0.75 * CGRectGetWidth(mainRect), 1.2*CGRectGetHeight(mainRect));

    UIImageView *leftImage = [[UIImageView alloc] initWithFrame:rLeft];
    UIImageView *rightImage = [[UIImageView alloc] initWithFrame:rRight];

    if (self.firstUserScore < self.secondUserScore) {
        leftImage.image = [UIImage imageNamed:@"leftRed"];
        rightImage.image = [UIImage imageNamed:@"rightGreen"];
    } else if (self.firstUserScore > self.secondUserScore) {
        leftImage.image = [UIImage imageNamed:@"leftGreen"];
        rightImage.image = [UIImage imageNamed:@"rightRed"];
    } else {
        return;
    }

    [self.tableView.backgroundView addSubview:rightImage];
    [self.tableView.backgroundView sendSubviewToBack:rightImage];
    [self.tableView.backgroundView addSubview:leftImage];
    [self.tableView.backgroundView sendSubviewToBack:leftImage];

    [UIView animateWithDuration:0.5
        delay:0.0
        options:UIViewAnimationOptionCurveEaseOut
        animations:^{
            leftImage.frame =
                CGRectMake(0, 0, CGRectGetWidth(leftImage.frame), 1.4 * CGRectGetHeight(mainRect));

            rightImage.frame =
                CGRectMake(0.25 * CGRectGetWidth(mainRect), -CGRectGetHeight(mainRect) * 0.2,
                           0.75 * CGRectGetWidth(mainRect), CGRectGetHeight(mainRect) * 1.2);
        }
        completion:^(BOOL finished){

        }];
}

- (BOOL)hidesBottomBarWhenPushed {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
