//
//  QZBPlayerPersonalPageVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 21/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBPlayerPersonalPageVC.h"
#import "QZBServerManager.h"
#import "QZBCurrentUser.h"
#import "QZBPlayerInfoCell.h"
#import "QZBTopicTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "QZBFriendHorizontalCell.h"
#import "QZBAchivHorizontalCell.h"
#import "QZBAchievement.h"
#import "JSBadgeView.h"
#import <TSMessages/TSMessage.h>
#import "QZBFriendsTVC.h"
#import "QZBAnotherUser.h"
#import "QZBRequestUser.h"
#import "QZBCategoryChooserVC.h"
#import <SCLAlertView-Objective-C/SCLAlertView.h>
#import "UIColor+QZBProjectColors.h"
#import "QZBVSScoreCell.h"
#import "QZBStatiscticCell.h"
#import <SVProgressHUD.h>
#import "UIViewController+QZBControllerCategory.h"
#import "UITableViewCell+QZBCellCategory.h"
#import "QZBGameTopic.h"
#import "QZBDescriptionForHorizontalCell.h"
#import "QZBRatingMainVC.h"
#import "QZBProgressViewController.h"
#import "QZBFriendsChallengeTVC.h"
#import "QZBAchievementManager.h"
#import "QZBAchievementCVC.h"
#import "QZBFindFriendsCell.h"
#import "NSObject+QZBSpecialCategory.h"
#import "QZBReportVC.h"
#import "QZBMessagerVC.h"
#import <CocoaLumberjack.h>


//#import "DBCameraViewController.h"
//#import "DBCameraContainerViewController.h"
//#import <DBCamera/DBCameraLibraryViewController.h>
//#import <DBCamera/DBCameraSegueViewController.h>

static NSString *playerIdentifier = @"playerСell";
static NSString *friendsIdentifier = @"friendsCell";
static NSString *achivIdentifier = @"achivCell";
static NSString *findFriendsIdentifier = @"searchFriends";
static NSString *mostLovedTopicIdentifier = @"mostLovedTopics";
static NSString *topicCellIdentifier = @"topicCell";
static NSString *challengeCell = @"challengeCell";
static NSString *vsScoreCellIndentifier = @"vsScoreCell";
static NSString *totalStatisticsIdentifier = @"totalStatistics";
static NSString *descriptionIdentifier = @"descriptionForHorizontal";
static NSInteger topicsOffset = 7;

@interface QZBPlayerPersonalPageVC () <UITableViewDataSource,
                                       UITableViewDelegate,
                                       UIActionSheetDelegate>

@property (strong, nonatomic) NSArray *achivArray;
@property (strong, nonatomic) id<QZBUserProtocol> user;
@property (strong, nonatomic) NSArray *friends;         // QZBAnotherUser
@property (strong, nonatomic) NSArray *friendRequests;  // QZBAnotherUser
@property (strong, nonatomic) NSArray *faveTopics;      // QZBGameTopic
@property (assign, nonatomic) BOOL isCurrent;
@property (assign, nonatomic) BOOL isFriend;

@property (strong, nonatomic) NSIndexPath *choosedIndexPath;
@property (strong, nonatomic) QZBGameTopic *choosedTopic;
@property (assign, nonatomic) BOOL isOnlineChallenge;

@end

@implementation QZBPlayerPersonalPageVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.playerTableView.delegate = self;
    self.playerTableView.dataSource = self;
    self.playerTableView.backgroundColor = [UIColor middleDarkGreyColor];

    [self setNeedsStatusBarAppearanceUpdate];

    [self initStatusbarWithColor:[UIColor blackColor]];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animate {
    [super viewWillAppear:animate];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userPressShowAllButton:)
                                                 name:@"QZBUserPressShowAllButton"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userPressSomethingInHorizontalTV:)
                                                 name:@"QZBUserPressSomethingInHorizontallTV"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(achievementGet:)
                                                 name:@"QZBAchievmentGet"
                                               object:nil];

    if (!self.user ||
        [self.user.userID isEqualToNumber:[QZBCurrentUser sharedInstance].user.userID]) {
        self.user = [QZBCurrentUser sharedInstance].user;
        [self updateCurentUser:self.user];
        self.isCurrent = YES;

    } else {
        self.isCurrent = NO;
    }
    self.navigationItem.title = self.user.name;
    if (self.isCurrent) {
        [self initFriendsWithUser:self.user];
    }
    // [self.tableView reloadData];

    DDLogInfo(@"viewWillAppear %@", self.user.name);

    [self updateBadges];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    self.user = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initPlayerPageWithUser:(id<QZBUserProtocol>)user {
    if ([user.userID isEqualToNumber:[QZBCurrentUser sharedInstance].user.userID] || !user) {
        self.user = [QZBCurrentUser sharedInstance].user;
        self.isCurrent = YES;
        [self updateCurentUser:user];

    } else {
        self.user = user;
        self.isCurrent = NO;

        self.navigationItem.rightBarButtonItem =
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                          target:self
                                                          action:@selector(showActionSheet)];

        self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    }

    [self updateCurentUser:user];

    [self initFriendsWithUser:self.user];

    DDLogInfo(@"user init %@", user);
}

- (void)updateCurentUser:(id<QZBUserProtocol>)user {
    [[QZBServerManager sharedManager] GETPlayerWithID:user.userID
        onSuccess:^(QZBAnotherUser *anotherUser) {

            self.faveTopics = anotherUser.faveTopics;
            self.achivArray = anotherUser.achievements;
            if ([user isKindOfClass:[QZBAnotherUser class]]) {
                QZBAnotherUser *currentUser = (QZBAnotherUser *)user;
                currentUser.userStatistics = anotherUser.userStatistics;

                self.user = currentUser;
                // self.faveTopics = anotherUser.faveTopics;

                if (!self.isCurrent) {
                    currentUser.isFriend = anotherUser.isFriend;
                    currentUser.imageURL = anotherUser.imageURL;
                }

            } else if ([user isKindOfClass:[QZBUser class]]) {
                QZBUser *u = (QZBUser *)user;

                u.userStatistics = anotherUser.userStatistics;
            }

            // self.user.isFriend = anotherUser.isFriend;
            DDLogInfo(@"is friend %d", user.isFriend);
            [self.tableView reloadData];
            [SVProgressHUD dismiss];

        }
        onFailure:^(NSError *error, NSInteger statusCode) {
            [SVProgressHUD showErrorWithStatus:QZBNoInternetConnectionMessage];

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)),
                           dispatch_get_main_queue(), ^{
                               [SVProgressHUD dismiss];
                           });

        }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    if (self.isCurrent) {
        self.user = nil;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger increment = 0;

    if (self.faveTopics.count > 0) {
        increment += self.faveTopics.count + 1;
    }
    if (!self.isCurrent) {
        increment += 1;
    }

    return 7 + increment;
}

// TODO refactoring

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell;

    if (indexPath.row == 0) {
        QZBPlayerInfoCell *playerCell =
            (QZBPlayerInfoCell *)[tableView dequeueReusableCellWithIdentifier:playerIdentifier];

        [self playerCellCustomInit:playerCell];

        return playerCell;
    } else if (indexPath.row == 1) {
        QZBStatiscticCell *userStatisticCell =
            [tableView dequeueReusableCellWithIdentifier:totalStatisticsIdentifier];

        [userStatisticCell setCellWithUser:self.user];

        return userStatisticCell;

    } else if (indexPath.row == 2) {

        QZBDescriptionForHorizontalCell *descrForHorizontal =
            [tableView dequeueReusableCellWithIdentifier:descriptionIdentifier];

        descrForHorizontal.descriptionLabel.text =
            [NSString stringWithFormat:@"Друзья (%ld):", (unsigned long)self.friends.count];

        descrForHorizontal.contentView.backgroundColor = [UIColor friendsLightGreyColor];

        return descrForHorizontal;

    } else if (indexPath.row == 3) {
        if (self.friends.count == 0) {
            if (self.isCurrent) {
                cell = [tableView dequeueReusableCellWithIdentifier:findFriendsIdentifier];
                QZBFindFriendsCell *ffCell = (QZBFindFriendsCell *)cell;
                if (self.friends) {
                    [ffCell.shadowView removeFromSuperview];
                }
                cell.contentView.backgroundColor = [UIColor friendsLightGreyColor];
                return cell;
            } else {
                QZBDescriptionForHorizontalCell *descrForHorizontal =
                    [tableView dequeueReusableCellWithIdentifier:descriptionIdentifier];
                // [descrForHorizontal.shadowView removeFromSuperview];

                descrForHorizontal.descriptionLabel.text =
                    @"У игрока еще нет друзей, добавьте его в "
                    @"друзья";
                return descrForHorizontal;

                // cell = [tableView dequeueReusableCellWithIdentifier:descriptionIdentifier];
            }
        } else {
            QZBFriendHorizontalCell *friendsHorizontalCell =
                [tableView dequeueReusableCellWithIdentifier:friendsIdentifier];

            [friendsHorizontalCell setFriendArray:self.friends];

            return friendsHorizontalCell;
        }

    } else if (indexPath.row == 4) {
        QZBDescriptionForHorizontalCell *descrForHorizontal =
            [tableView dequeueReusableCellWithIdentifier:descriptionIdentifier];

        descrForHorizontal.descriptionLabel.text = [NSString
            stringWithFormat:@"Достижения (%ld):", (unsigned long)self.achivArray.count];

        descrForHorizontal.contentView.backgroundColor = [UIColor whiteColor];

        return descrForHorizontal;

    } else if (indexPath.row == 5) {
        QZBAchivHorizontalCell *achivCell =
            [tableView dequeueReusableCellWithIdentifier:achivIdentifier];
        achivCell.contentView.backgroundColor = [UIColor whiteColor];

        [achivCell setAchivArray:self.achivArray];


        return achivCell;

    } else if (indexPath.row == [tableView numberOfRowsInSection:0] - 1) {
        if (self.isCurrent) {
            if (!self.friends.count == 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:findFriendsIdentifier];
                cell.contentView.backgroundColor = [UIColor middleDarkGreyColor];
                
                return cell;
            } else {
                QZBDescriptionForHorizontalCell *descrCell =
                    [tableView dequeueReusableCellWithIdentifier:descriptionIdentifier];
                descrCell.descriptionLabel.text = @"";
                descrCell.contentView.backgroundColor = [UIColor middleDarkGreyColor];
                return descrCell;
            }
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:challengeCell];
            return cell;
        }

    } else if (indexPath.row == 6 && self.faveTopics.count > 0) {
        QZBDescriptionForHorizontalCell *descrForHorizontal =
            [tableView dequeueReusableCellWithIdentifier:descriptionIdentifier];

        descrForHorizontal.descriptionLabel.text = @"Любимые топики";
        descrForHorizontal.descriptionLabel.textColor = [UIColor whiteColor];

        descrForHorizontal.contentView.backgroundColor = [UIColor veryDarkGreyColor];

        return descrForHorizontal;

    } else if (!self.isCurrent && indexPath.row == [tableView numberOfRowsInSection:0] - 2) {
        QZBVSScoreCell *vsCell =
            [tableView dequeueReusableCellWithIdentifier:vsScoreCellIndentifier];
        [vsCell setCellWithUser:self.user];

        vsCell.contentView.backgroundColor = [UIColor middleDarkGreyColor];
        return vsCell;

    }

    else if (indexPath.row > 6) {
        QZBTopicTableViewCell *topicCell =
            [tableView dequeueReusableCellWithIdentifier:topicCellIdentifier];

        QZBGameTopic *topic = self.faveTopics[indexPath.row - topicsOffset];

        topicCell.topicName.text = topic.name;

        NSInteger level = 0;
        float progress = 0.0;

        [NSObject calculateLevel:&level
                   levelProgress:&progress
                       fromScore:[topic.points integerValue]];

        [topicCell initCircularProgressWithLevel:level
                                        progress:progress
                                         visible:[topic.visible boolValue]];

        topicCell.backgroundColor = [UIColor veryDarkGreyColor];

        return topicCell;
    }

    return cell;
}

- (void)userPressShowAllButton:(NSNotification *)notification {
    DDLogInfo(@"%@", notification.object);

    NSIndexPath *indexPath = (NSIndexPath *)notification.object;

    if (indexPath.row == 3) {
        [self performSegueWithIdentifier:@"showFriendsList" sender:nil];
    } else if (indexPath.row == 5) {
        [self performSegueWithIdentifier:@"showAchivements" sender:nil];
    }
}

- (void)userPressSomethingInHorizontalTV:(NSNotification *)notification {
    if ([notification.name isEqualToString:@"QZBUserPressSomethingInHorizontallTV"]) {
        // NSDictionary *dict = @{@"indexInLocalTable":indexPath,@"indexInGlobalTable": globalIP};
        NSDictionary *dict = notification.object;
        NSIndexPath *globabalIP = dict[@"indexInGlobalTable"];
        NSIndexPath *localIP = dict[@"indexInLocalTable"];

        if (globabalIP.row == 3) {
            QZBUser *user = self.friends[localIP.row];

            QZBPlayerPersonalPageVC *personalVC =
                [self.storyboard instantiateViewControllerWithIdentifier:@"friendStoryboardID"];
            [personalVC initPlayerPageWithUser:user];
            [self.navigationController pushViewController:personalVC animated:YES];

        } else if (globabalIP.row == 5) {
            QZBAchievement *achiev = self.achivArray[localIP.row];
            [self showAchievement:achiev];
        }
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.choosedIndexPath isEqual:indexPath]) {
        return 130.0f;
    }
    if (indexPath.row == 6 && self.faveTopics.count == 0) {
        return 74.0;
    }
    
    if(indexPath.row == 1){
        return 105.0;
    }else
    if (indexPath.row < 2 || indexPath.row == 3 || indexPath.row == 5) {
        return 127.0f;
    } else if (indexPath.row == 2 || indexPath.row == 4 || indexPath.row == 6) {
        return 32.0f;
    } else {
        return 74.0f;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if([cell isKindOfClass:[QZBTopicTableViewCell class]]){
        QZBTopicTableViewCell *topicCell = (QZBTopicTableViewCell *)cell;
        if(!topicCell.visible){
            self.choosedIndexPath = nil;
            [tableView beginUpdates];
            [tableView endUpdates];
            [self showAlertAboutUnvisibleTopic:topicCell.topicName.text];//REDO
            
            return;
        }
    }
    
    
    NSString *identifier = cell.reuseIdentifier;

    if ([identifier isEqualToString:@"searchFriends"]) {
        [self performSegueWithIdentifier:@"showSearch" sender:nil];
    } else if ([identifier isEqualToString:@"challengeCell"]) {
        [self performSegueWithIdentifier:@"challengeSegue" sender:nil];
    } else if ([identifier isEqualToString:topicCellIdentifier]) {
        if ([self.choosedIndexPath isEqual:indexPath]) {
            self.choosedIndexPath = nil;
        } else {
            self.choosedIndexPath = indexPath;
        }

        [tableView beginUpdates];
        [tableView endUpdates];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (buttonIndex == 0) {
        // Make user response

        if (self.user) {
            [self performSegueWithIdentifier:@"showReportScreen" sender:nil];
        }

        // TODO
    }else if(buttonIndex == 1){
        [self performSegueWithIdentifier:@"pushMessager" sender:nil];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
// preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    if ([segue.identifier isEqualToString:@"showAchivements"]) {
        QZBAchievementCVC *destinationVC = segue.destinationViewController;

        [destinationVC initAchievmentsWithGettedAchievements:self.achivArray];

    }

    else if ([segue.identifier isEqualToString:@"showFriendsList"]) {
        QZBFriendsTVC *vc = (QZBFriendsTVC *)segue.destinationViewController;

        [vc setFriendsOwner:self.user friends:self.friends friendsRequests:self.friendRequests];
    } else if ([segue.identifier isEqualToString:@"challengeSegue"]) {
        QZBCategoryChooserVC *destinationVC = segue.destinationViewController;
        [destinationVC initWithUser:self.user];

    } else if ([segue.identifier isEqualToString:@"showPreparingVC"]) {
        QZBProgressViewController *navigationController = segue.destinationViewController;

        if (!self.isOnlineChallenge) {
            [navigationController initSessionWithTopic:self.choosedTopic user:nil];
            self.isOnlineChallenge = NO;

        } else {
            [navigationController initSessionWithTopic:self.choosedTopic user:self.user];
            self.isOnlineChallenge = NO;
        }

    } else if ([segue.identifier isEqualToString:@"showRate"]) {
        QZBRatingMainVC *destinationVC = segue.destinationViewController;
        [destinationVC initWithTopic:self.choosedTopic];

    } else if ([segue.identifier isEqualToString:@"showFriendsChallenge"]) {
        QZBFriendsChallengeTVC *destinationVC = segue.destinationViewController;
        QZBUser *user = [QZBCurrentUser sharedInstance].user;

        if (self.friends) {
            [destinationVC setFriendsOwner:user
                                andFriends:self.friends
                                 gameTopic:self.choosedTopic];
        }

    } else if ([segue.identifier isEqualToString:@"showReportScreen"]) {
        QZBReportVC *destVC = (QZBReportVC *)segue.destinationViewController;

        [destVC initWithUser:self.user];
    }else if([segue.identifier isEqualToString:@"pushMessager"]){
        QZBMessagerVC *destVC = (QZBMessagerVC *)segue.destinationViewController;
        
        [destVC initWithUser:self.user];
        
       // [destVC initWithUser:self.user userpic:];
        
    }
}

#pragma mark - actions
- (IBAction)showAchivements:(UIButton *)sender {
    [self showAchievementsTapAction:nil];
}
- (IBAction)showFriendsAction:(id)sender {
    [self showFriendsTapAction:nil];
}

- (void)showFriendsTapAction:(id)sender {
   
    [self performSegueWithIdentifier:@"showFriendsList" sender:nil];
}

- (void)showAchievementsTapAction:(id)sender {
    [self performSegueWithIdentifier:@"showAchivements" sender:nil];
}

- (void)multiUseButtonAction:(id)sender {
    if (self.isCurrent) {
        [self performSegueWithIdentifier:@"showSettings" sender:nil];
    } else {
        NSNumber *friendID = self.user.userID;
        if (!self.user.isFriend) {
            [[QZBServerManager sharedManager] POSTFriendWithID:friendID
                onSuccess:^{

                    [TSMessage showNotificationInViewController:self
                                                          title:@"Друг добавлен"
                                                       subtitle:@""
                                                           type:TSMessageNotificationTypeSuccess
                                                       duration:1];
                    if ([self.user isKindOfClass:[QZBAnotherUser class]]) {
                        QZBAnotherUser *currentUser = (QZBAnotherUser *)self.user;
                        currentUser.isFriend = YES;
                        [self.tableView reloadData];
                    }

                }
                onFailure:^(NSError *error, NSInteger statusCode){

                }];
        } else {
            [[QZBServerManager sharedManager] DELETEUNFriendWithID:friendID
                onSuccess:^{

                    [TSMessage showNotificationInViewController:self
                                                          title:@"Друг удален"
                                                       subtitle:@""
                                                           type:TSMessageNotificationTypeSuccess
                                                       duration:1];
                    if ([self.user isKindOfClass:[QZBAnotherUser class]]) {
                        QZBAnotherUser *currentUser = (QZBAnotherUser *)self.user;
                        currentUser.isFriend = NO;
                        [self.tableView reloadData];
                    }
                }
                onFailure:^(NSError *error, NSInteger statusCode){

                }];
        }
    }
}

- (void)showActionSheet {
    UIActionSheet *actSheet = [[UIActionSheet alloc]
                 initWithTitle:@"Пожаловаться на пользователя"
                      delegate:self
             cancelButtonTitle:@"Отменить"
        destructiveButtonTitle:nil
                               otherButtonTitles:@"Пожаловаться",@"Написать сообщение", nil];

    [actSheet showInView:self.view];
}

- (IBAction)playButtonAction:(UIButton *)sender {
    UITableViewCell *cell = [self parentCellForView:sender];
    if (cell != nil) {
        NSIndexPath *indexPath = [self.playerTableView indexPathForCell:cell];

        self.choosedTopic = self.faveTopics[indexPath.row - topicsOffset];

        [self performSegueWithIdentifier:@"showPreparingVC" sender:nil];
    }
}
- (IBAction)challengeAction:(id)sender {
    UITableViewCell *cell = [self parentCellForView:sender];
    if (cell != nil) {
        NSIndexPath *indexPath = [self.playerTableView indexPathForCell:cell];
        
        self.choosedTopic = self.faveTopics[indexPath.row - topicsOffset];

        if (self.isCurrent) {
            self.isOnlineChallenge = NO;
            [self performSegueWithIdentifier:@"showFriendsChallenge" sender:nil];

        } else {
            self.isOnlineChallenge = YES;
            [self performSegueWithIdentifier:@"showPreparingVC" sender:nil];
        }
    }
}
- (IBAction)rateAction:(UIButton *)sender {
    UITableViewCell *cell = [self parentCellForView:sender];
    if (cell != nil) {
        NSIndexPath *indexPath = [self.playerTableView indexPathForCell:cell];
        
        self.choosedTopic = self.faveTopics[indexPath.row - topicsOffset];

        [self performSegueWithIdentifier:@"showRate" sender:nil];
    }
}

#pragma mark - init friends and achivs

- (void)playerCellCustomInit:(QZBPlayerInfoCell *)playerCell {
    [playerCell.multiUseButton addTarget:self
                                  action:@selector(multiUseButtonAction:)
                        forControlEvents:UIControlEventTouchUpInside];

    if (self.friends) {
        playerCell.friendsButton.enabled = YES;
        playerCell.friendsLabel.text =
            [NSString stringWithFormat:@"%ld", (unsigned long)[self.friends count]];
        playerCell.friendsLabel.alpha = 1.0;
    }

    NSString *buttonTitle = nil;
    if (self.isCurrent) {
        buttonTitle = @"Настройки";
        [playerCell.multiUseButton setTitle:@"settings" forState:UIControlStateNormal];

        if (self.friendRequests) {
            [playerCell setBAdgeCount:[self badgeNumber]];
        }
    } else {
        if (!self.user.isFriend) {
            buttonTitle = @"Добавить в друзья";
        } else {
            buttonTitle = @"Удалить из друзей";
        }
    }
    [playerCell.multiUseButton setTitle:buttonTitle forState:UIControlStateNormal];

    

    if(self.user.imageURL){
        [playerCell.playerUserpic setImageWithURL:self.user.imageURL];
    }else{
        [playerCell.playerUserpic setImage:[UIImage imageNamed:@"userpicStandart"]];
    }

    NSNumber *allAchievementsCount = @([QZBAchievementManager sharedInstance].achievements.count);

    NSNumber *currentAchievementsCount = @(self.achivArray.count);

    playerCell.achievementLabel.text =
        [NSString stringWithFormat:@"%@/%@", currentAchievementsCount, allAchievementsCount];

    // cell = playerCell;
}

#pragma mark - friends

- (void)initFriendsWithUser:(id<QZBUserProtocol>)user {
    [[QZBServerManager sharedManager] GETAllFriendsOfUserWithID:user.userID
        OnSuccess:^(NSArray *friends) {
            self.friends = friends;
            [self.tableView reloadData];

        }
        onFailure:^(NSError *error, NSInteger statusCode){

        }];

    if (self.isCurrent) {
        [[QZBServerManager sharedManager] GETFriendsRequestsOnSuccess:^(NSArray *friends) {

            self.friendRequests = friends;
            [self.tableView reloadData];

            UITabBarController *tabController = self.tabBarController;
            UITabBarItem *tabbarItem = tabController.tabBar.items[2];

            if ([self badgeNumber] > 0) {
                tabbarItem.badgeValue =
                    [NSString stringWithFormat:@"%ld", (long)[self badgeNumber]];

            } else {
                tabbarItem.badgeValue = nil;
            }

        } onFailure:^(NSError *error, NSInteger statusCode){

        }];
    }
}

- (void)updateBadges {
    if (self.isCurrent) {
        [[QZBServerManager sharedManager] GETFriendsRequestsOnSuccess:^(NSArray *friends) {

            self.friendRequests = friends;
            [self.tableView reloadData];

            UITabBarController *tabController = self.tabBarController;
            UITabBarItem *tabbarItem = tabController.tabBar.items[2];

            if ([self badgeNumber] > 0) {
                tabbarItem.badgeValue =
                    [NSString stringWithFormat:@"%ld", (long)[self badgeNumber]];

            } else {
                tabbarItem.badgeValue = nil;
            }

        } onFailure:^(NSError *error, NSInteger statusCode){

        }];
    }
}

- (NSInteger)badgeNumber {
    NSInteger count = 0;

    for (QZBRequestUser *user in self.friendRequests) {
        if (!user.viewed) {
            count++;
        }
    }
    return count;
}

#pragma mark - achievment



- (void)showAchievement:(QZBAchievement *)achievment {
    // QZBAchievement *achievment = self.achivArray[indexPath.row];

    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.backgroundType = Blur;
    alert.showAnimationType = FadeIn;
    alert.shouldDismissOnTapOutside = YES;

    [alert alertIsDismissed:^{

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
                           [self setNeedsStatusBarAppearanceUpdate];
                       });

    }];

    UIImageView *v = [[UIImageView alloc] init];

    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:achievment.imageURL
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];

    [v setImageWithURLRequest:imageRequest
              placeholderImage:[UIImage imageNamed:@"achiv"]
                       success:nil
                       failure:nil];

    // UIImage *img =

    [alert showCustom:self.navigationController
                   image:v.image
                   color:[UIColor lightBlueColor]
                   title:achievment.name
                subTitle:achievment.achievementDescription
        closeButtonTitle:@"ОК"
                duration:0.0f];
}

- (void)achievementGet:(NSNotification *)note {
    [self showAlertAboutAchievmentWithDict:note.object];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
