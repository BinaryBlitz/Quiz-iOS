//
//  QZBMainGameScreenTVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 18/03/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBMainGameScreenTVC.h"
#import "QZBServerManager.h"
#import "QZBMainChallengesCell.h"
#import "UIViewController+QZBControllerCategory.h"
#import "UIColor+QZBProjectColors.h"
#import "QZBTopicTableViewCell.h"
#import "QZBDescriptionCell.h"  //mainDescriptionCell
#import <SVProgressHUD.h>
#import "QZBChallengeCell.h"
#import "QZBChallengeDescription.h"
#import "QZBChallengeDescriptionWithResults.h"
#import "QZBGameTopic.h"
#import "QZBProgressViewController.h"
#import "UIView+QZBShakeExtension.h"
#import "NSObject+QZBSpecialCategory.h"
#import "CoreData+MagicalRecord.h"
#import "QZBResultOfSessionCell.h"
#import "QZBAnotherUser.h"
#import "QZBEndGameVC.h"
#import "QZBRoomInvite.h"
#import "QZBRoom.h"
#import "QZBRoomController.h"
#import "QZBRoomOnMainCell.h"
#import "UIFont+QZBCustomFont.h"
//#import "UIViewController+QZBMessagerCategory.h"

NSString *const QZBNewQuestionControllerSegueIdentifier =
@"QZBNewQuestionControllerSegueIdentifier";

@interface QZBMainGameScreenTVC ()

@property (strong, nonatomic) NSArray *roomArray;
@property (strong, nonatomic) NSArray *faveTopics;
@property (strong, nonatomic) NSArray *friendsTopics;
@property (strong, nonatomic) NSArray *featured;
@property (strong, nonatomic) NSArray *recent;
@property (strong, nonatomic) NSArray *additionalTopics;
@property (strong, nonatomic) NSMutableArray *challenges;
@property (strong, nonatomic) NSMutableArray *challenged;
@property (strong, nonatomic) NSMutableArray *roomsIvites;
@property (strong, nonatomic) NSMutableArray *workArray;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) QZBChallengeDescription *challengeDescription;
@property (strong, nonatomic) QZBChallengeDescriptionWithResults *challengeDescriptionWithResults;
@property (strong, nonatomic) QZBRoomInvite *roomInvite;
@property (strong, nonatomic) QZBRoom *room;

@end

@implementation QZBMainGameScreenTVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    self.mainTableView.backgroundColor = [UIColor veryDarkGreyColor];

    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(reloadTopicsData)
                  forControlEvents:UIControlEventValueChanged];

    [self.mainTableView addSubview:self.refreshControl];

    [self addBarButtonRight];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTopicsDataFromNotification:)
                                                 name:@"QZBNeedUpdateMainScreen"
                                               object:nil];

    [self.refreshControl beginRefreshing];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSMutableArray *)workArray {
    if (!_workArray) {
        _workArray = [NSMutableArray array];
    }
    return _workArray;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // self.workArray = [NSMutableArray array];

    self.title = @"1 на 1";  // REDO

    [self initStatusbarWithColor:[UIColor blackColor]];

    UITabBarController *tabController = self.tabBarController;
    UITabBarItem *tabbarItem = tabController.tabBar.items[2];
    tabbarItem.badgeValue = nil;

    // [self.refreshControl beginRefreshing];

    //  [self subscribeToMessages];

    [self reloadTopicsData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    UITabBarController *tabController = self.tabBarController;
    UITabBarItem *tabbarItem = tabController.tabBar.items[2];
    tabbarItem.badgeValue = nil;

    //[self.tabBarController]
    //[self unsubscribeFromMessages];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self.mainTableView beginUpdates];
    [self.mainTableView endUpdates];
    if ([segue.identifier isEqualToString:@"showPreparingVC"] && self.challengeDescription) {
        QZBProgressViewController *destinationController = segue.destinationViewController;

        [destinationController initSessionWithDescription:self.challengeDescription];

        self.challengeDescription = nil;

    } else if ([segue.identifier isEqualToString:@"showSessionResult"] &&
               self.challengeDescriptionWithResults) {
        QZBEndGameVC *destinationVC = segue.destinationViewController;

        [destinationVC initWithChallengeResult:self.challengeDescriptionWithResults];
        self.challengeDescriptionWithResults = nil;
    } else if ([segue.identifier isEqualToString:@"showRoomFromInvite"]) {
        QZBRoomController *roomController = (QZBRoomController *)segue.destinationViewController;
        NSDictionary *roomDict = @{ @"id" : self.roomInvite.roomID };
        QZBRoom *room = [[QZBRoom alloc] initWithDictionary:roomDict];
        [roomController initWithRoom:room];
        self.roomInvite = nil;
    } else if ([segue.identifier isEqualToString:@"showRoomFromMain"]) {
        //  QZBRoom *room = self.roomArray
        QZBRoomController *destinationController = segue.destinationViewController;
        [destinationController initWithRoom:self.room];
        self.room = nil;

    } else {
        [super prepareForSegue:segue sender:sender];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.workArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *arr = self.workArray[section];

    if (arr == self.roomArray) {
        return arr.count + 2;
    }

    return arr.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
        QZBDescriptionCell *cell =
            [tableView dequeueReusableCellWithIdentifier:@"mainDescriptionCell"];

        cell.backgroundColor = [self colorForSection:indexPath.section];

        return cell;
    }

    NSArray *arr = self.workArray[indexPath.section];

    if (arr == self.roomArray) {
        if (indexPath.row < arr.count) {
            QZBRoomOnMainCell *cell =
                [tableView dequeueReusableCellWithIdentifier:@"roomsCellOnMainIdentifier"];

            cell.backgroundColor = [self colorForSection:indexPath.section];

            QZBRoom *room = arr[indexPath.row];

            cell.roomUpLabel.text = [room participantsDescription];
            cell.roomDownLabel.text = [room topicsDescription];

            return cell;
        } else {
            UITableViewCell *cell =
                [tableView dequeueReusableCellWithIdentifier:@"showAllRoomsCellIdentifier"];

            cell.backgroundColor = [self colorForSection:indexPath.section];
            return cell;
        }
    }
    if (arr == self.roomsIvites) {
        QZBResultOfSessionCell *cell =
            [tableView dequeueReusableCellWithIdentifier:@"resultSessionCell"];

        QZBRoomInvite *rI = arr[indexPath.row];

        cell.backgroundColor = [self colorForSection:indexPath.section];
        cell.topicNameLabel.text =
            [NSString stringWithFormat:@"Комната %@", rI.roomID];  // descr.topic.name;
        if (rI.name) {
            cell.opponentNameLabel.text = [NSString stringWithFormat:@"От %@", rI.name];
        } else {
            cell.opponentNameLabel.text = @"";
        }

        return cell;

    } else if (arr == self.challenges) {
        QZBChallengeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"challengeCell"];
        cell.backgroundColor = [self colorForSection:indexPath.section];

        QZBChallengeDescription *descr = arr[indexPath.row];

        cell.topicNameLabel.text = descr.topicName;
        cell.opponentNameLabel.text = descr.name;
        // cell.visible = descr.topic.visible;

        return cell;

    } else if (arr == self.challenged) {
        QZBResultOfSessionCell *cell =
            [tableView dequeueReusableCellWithIdentifier:@"resultSessionCell"];

        QZBChallengeDescriptionWithResults *descr = self.challenged[indexPath.row];

        cell.backgroundColor = [self colorForSection:indexPath.section];
        cell.topicNameLabel.text = descr.topic.name;
        cell.opponentNameLabel.text =
            [NSString stringWithFormat:@"%@ (%@)", descr.opponentUser.name, descr.sessionResult];

        return cell;

    } else {
        QZBTopicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"topicCell"];

        // NSArray *arr = self.workArray[indexPath.section];

        QZBGameTopic *topic = arr[indexPath.row];

        cell.backgroundColor = [self colorForSection:indexPath.section];

        //        NSInteger level = 0;
        //        float progress = 0.0;
        //
        //        [NSObject calculateLevel:&level
        //                   levelProgress:&progress
        //                       fromScore:[topic.points integerValue]];
        //
        //        [cell initCircularProgressWithLevel:level
        //                                   progress:progress
        //                                    visible:[topic.visible boolValue]];
        //
        //        cell.topicName.text = topic.name;
        [cell initWithTopic:topic];

        return cell;
    }
}

- (UIColor *)colorForSection:(NSInteger)section {  // test
    UIColor *color = [UIColor veryDarkGreyColor];

    NSArray *arr = self.workArray[section];

    if (arr == self.faveTopics) {
        color = [UIColor ultralightGreenColor];
    } else if (arr == self.friendsTopics) {
        color = [UIColor lightCyanColor];
    } else if (arr == self.featured) {
        color = [UIColor lightPincColor];
    } else if (arr == self.challenges) {
        color = [UIColor lightGreenColor];
    } else if (arr == self.additionalTopics) {
    } else if (arr == self.challenged) {
        color = [UIColor challengedColor];  // strongGreenColor];
    } else if (arr == self.roomsIvites) {
        color = [UIColor roomInvitesColor];
    } else if (arr == self.roomArray) {
        color = [UIColor roomColor];
    } else if (arr == self.recent){
        color = [UIColor sandColor];
    }

    return color;
}

- (NSString *)textForArray:(NSArray *)arr {  // test
    NSString *text = @"";

    if (arr == self.faveTopics) {
        text = @"Любимые темы";
    } else if (arr == self.friendsTopics) {
        text = @"Популярное у друзей";
    } else if (arr == self.featured) {
        text = @"Популярные темы";
    } else if (arr == self.challenges) {
        text = @"Брошенные вызовы";
    } else if (arr == self.additionalTopics) {
        text = @"Сыграйте эти темы";
    } else if (arr == self.challenged) {
        text = @"Результаты";
    } else if (arr == self.roomsIvites) {
        text = @"Приглашения в комнаты";
    } else if (arr == self.roomArray) {
        text = @"Комнаты";
    } else if(arr == self.recent){
        text = @"Новые темы";
    }
    return text;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.reuseIdentifier isEqualToString:@"roomsCellOnMainIdentifier"]) {
        self.room = self.roomArray[indexPath.row];
        [self performSegueWithIdentifier:@"showRoomFromMain" sender:nil];
    } else if ([cell.reuseIdentifier isEqualToString:@"showAllRoomsCellIdentifier"]) {
        [self showRoomsList];
    } else if ([cell.reuseIdentifier isEqualToString:@"mainChallengeCell"]) {
        [self performSegueWithIdentifier:@"showChallenges" sender:nil];
    } else if ([cell.reuseIdentifier isEqualToString:@"mainDescriptionCell"]) {
        return;
    } else {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#(NSString *)#>
    if ([self isLastCellForIndexPath:indexPath]) {
        return 10.0;
    }

    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (BOOL)isLastCellForIndexPath:(NSIndexPath *)indexPath {
    //   NSArray *arr = self.workArray[indexPath.section];

    //   NSLog(@"section %ld row %ld", indexPath.section, indexPath.row);

    NSInteger count = [self tableView:self.mainTableView numberOfRowsInSection:indexPath.section];

    if (indexPath.row == count - 1) {
        return YES;
    } else {
        return NO;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];

    view.backgroundColor = [self colorForSection:section];

    CGRect rect = CGRectMake(0, 7, CGRectGetWidth(tableView.frame), 42);

    UILabel *label = [[UILabel alloc] initWithFrame:rect];

    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldMuseoFontOfSize:20];

    if (section > 0) {
        [view addDropShadowsForView];
    }

    [view addSubview:label];

    NSArray *arr = self.workArray[section];

    label.text = [[self textForArray:arr] uppercaseString];

    return view;
}
//-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//    // CGRect rect = CGRectMake(0, 0,CGRectGetWidth(tableView.frame), 48);
//
//    //    if(section==0){
//    //        return nil;
//    //    }
//
//    UIView *view = [[UIView alloc] init];
//
//    view.backgroundColor = [self colorForSection:section];
//
//    CGRect rect = CGRectMake(0, 7, CGRectGetWidth(tableView.frame), 42);
//
//    UILabel *label = [[UILabel alloc] initWithFrame:rect];
//
//    label.textAlignment = NSTextAlignmentCenter;
//    label.textColor = [UIColor whiteColor];
//    label.font = [UIFont boldMuseoFontOfSize:20];
//
//    if (section > 0) {
//        [view addDropShadowsForView];
//    }
//
//    [view addSubview:label];
//
//    NSArray *arr = self.workArray[section];
//
//    label.text = [[self textForArray:arr] uppercaseString];
//
//    return view;
//}

#pragma mark - actions

- (IBAction)playGameAction:(id)sender {
    UITableViewCell *cell = [self parentCellForView:sender];

    if (cell) {
        if (![self checkCanPlayTopic:cell]) {
            return;
        }

        NSIndexPath *ip = [self.mainTableView indexPathForCell:cell];

        NSArray *arr = self.workArray[ip.section];

        self.choosedTopic = arr[ip.row];
        self.choosedIndexPath = nil;

        [self performSegueWithIdentifier:@"showPreparingVC" sender:nil];
    }
}

- (IBAction)throwChallengeAction:(id)sender {
    UITableViewCell *cell = [self parentCellForView:sender];

    if (cell) {
        if (![self checkCanPlayTopic:cell]) {
            return;
        }

        NSIndexPath *ip = [self.mainTableView indexPathForCell:cell];

        NSArray *arr = self.workArray[ip.section];

        self.choosedTopic = arr[ip.row];
        self.choosedIndexPath = nil;

        //[self performSegueWithIdentifier:@"showPreparingVC" sender:nil];

        //[self performSegueWithIdentifier:@"showRate" sender:nil];
        [self performSegueWithIdentifier:@"showFriendsChallenge" sender:nil];
    }
}
- (IBAction)showRateAction:(id)sender {
    UITableViewCell *cell = [self parentCellForView:sender];

    if (cell) {
        NSIndexPath *ip = [self.mainTableView indexPathForCell:cell];

        NSArray *arr = self.workArray[ip.section];

        self.choosedTopic = arr[ip.row];
        self.choosedIndexPath = nil;

        //[self performSegueWithIdentifier:@"showPreparingVC" sender:nil];
        // [self performSegueWithIdentifier:@"showFriendsChallenge" sender:nil];

        [self performSegueWithIdentifier:@"showRate" sender:nil];
    }
}
- (IBAction)acceptChallengeAction:(UIButton *)sender {
    UITableViewCell *cell = [self parentCellForView:sender];

    if (cell) {
        NSIndexPath *ip = [self.mainTableView indexPathForCell:cell];

        NSMutableArray *arr = self.workArray[ip.section];

        QZBChallengeDescription *description = arr[ip.row];
        [arr removeObject:description];
        [self.mainTableView beginUpdates];
        [self.mainTableView deleteRowsAtIndexPaths:@[ ip ]
                                  withRowAnimation:UITableViewRowAnimationRight];
        [self.mainTableView endUpdates];

        // self.challengeDescription = description;

        self.choosedIndexPath = nil;
        [self.topicTableView beginUpdates];
        [self.topicTableView endUpdates];

        if (![description.topic.visible boolValue]) {
            QZBChallengeCell *challengeCell = (QZBChallengeCell *)cell;

            [self showAlertAboutUnvisibleTopic:challengeCell.topicNameLabel.text];
            return;
        }

        self.challengeDescription = description;

        [self performSegueWithIdentifier:@"showPreparingVC" sender:nil];
    }
}

- (IBAction)declineChallengeAction:(id)sender {
    UITableViewCell *cell = [self parentCellForView:sender];

    if (cell) {
        NSIndexPath *ip = [self.mainTableView indexPathForCell:cell];
        NSMutableArray *arr = self.workArray[ip.section];
        QZBChallengeDescription *description = arr[ip.row];
        NSNumber *lobbyNumber = description.lobbyID;

        [self ignoreInteractions];

        self.choosedIndexPath = nil;

        [self deleteRowWithAnimationOnIdexPath:ip array:self.challenges];

        [[QZBServerManager sharedManager] POSTDeclineChallengeWhithLobbyID:lobbyNumber
            onSuccess:^{
            }
            onFailure:^(NSError *error, NSInteger statusCode){
            }];
    }
}
//это работает еще и для комнат
- (IBAction)showChallengeResultActrion:(UIButton *)sender {
    UITableViewCell *cell = [self parentCellForView:sender];

    if (cell) {
        NSIndexPath *ip = [self.mainTableView indexPathForCell:cell];
        NSMutableArray *arr = self.workArray[ip.section];

        self.choosedIndexPath = nil;
        [self.topicTableView beginUpdates];
        [self.topicTableView endUpdates];

        if (arr == self.challenged) {
            QZBChallengeDescriptionWithResults *description = arr[ip.row];
            self.challengeDescriptionWithResults = description;

            [self performSegueWithIdentifier:@"showSessionResult" sender:nil];

        } else if (arr == self.roomsIvites) {
            QZBRoomInvite *roomInvite = arr[ip.row];
            self.roomInvite = roomInvite;
            [self hideRoomIvite:roomInvite];
            [self performSegueWithIdentifier:@"showRoomFromInvite" sender:nil];
        }

        // QZBChallengeDescriptionWithResults *description = arr[ip.row];

        // self.challengeDescription = description;
        //
        //        self.choosedIndexPath = nil;
        //        [self.topicTableView beginUpdates];
        //        [self.topicTableView endUpdates];

        //        self.challengeDescriptionWithResults = description;
        //
        //        [self performSegueWithIdentifier:@"showSessionResult" sender:nil];
    }
}

- (IBAction)hideChallengeResultAction:(UIButton *)sender {  // TEST
    UITableViewCell *cell = [self parentCellForView:sender];
    if (cell) {
        NSIndexPath *ip = [self.mainTableView indexPathForCell:cell];
        NSMutableArray *arr = self.workArray[ip.section];

        self.choosedIndexPath = nil;
        if (arr == self.challenged) {
            QZBChallengeDescriptionWithResults *description = arr[ip.row];

            [[QZBServerManager sharedManager] DELETELobbiesWithID:description.lobbyID
                                                        onSuccess:nil
                                                        onFailure:nil];
            [self deleteRowWithAnimationOnIdexPath:ip array:self.challenged];

        } else if (arr == self.roomsIvites) {
            QZBRoomInvite *roomInvite = arr[ip.row];

            [self hideRoomIvite:roomInvite];
            [self deleteRowWithAnimationOnIdexPath:ip array:self.roomsIvites];
        }
        [self ignoreInteractions];

        //  self.choosedIndexPath = nil;

        //        [self deleteRowWithAnimationOnIdexPath:ip
        //                                         array:self.challenged];

        //        [[QZBServerManager sharedManager]DELETELobbiesWithID:description.lobbyID
        //                                                   onSuccess:nil
        //                                                   onFailure:nil];
    }
}

- (void)hideRoomIvite:(QZBRoomInvite *)roomInvite {
    [[QZBServerManager sharedManager] DELETEDeleteRoomInviteWithID:roomInvite.roomInviteID
                                                         onSuccess:nil
                                                         onFailure:nil];
}

- (void)showRoomsList {
    [self performSegueWithIdentifier:@"showRoomList" sender:nil];
}

- (void)ignoreInteractions {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                   });
}

- (void)deleteRowWithAnimationOnIdexPath:(NSIndexPath *)ip array:(NSMutableArray *)arr {
    [self.mainTableView beginUpdates];

    [self.mainTableView deleteRowsAtIndexPaths:@[ ip ]
                              withRowAnimation:UITableViewRowAnimationRight];
    [arr removeObjectAtIndex:ip.row];

    if (arr.count == 0) {
        NSUInteger numInWorkArray = ip.section;  //[self.workArray indexOfObject:arr];
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:numInWorkArray];
        [self.mainTableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationRight];
        [self.workArray removeObjectAtIndex:ip.section];
    }

    [self.mainTableView endUpdates];
}

- (BOOL)checkCanPlayTopic:(UITableViewCell *)cell {
    if ([cell isKindOfClass:[QZBTopicTableViewCell class]]) {
        QZBTopicTableViewCell *topicCell = (QZBTopicTableViewCell *)cell;
        if (!topicCell.visible) {
            self.choosedIndexPath = nil;
            [self.mainTableView beginUpdates];
            [self.mainTableView endUpdates];
            [self showAlertAboutUnvisibleTopic:topicCell.topicName.text];  // REDO

            return NO;
        } else {
            return YES;
        }
    }

    return YES;
}

#pragma mark - reload topics

- (void)reloadTopicsDataFromNotification:(NSNotification *)note {
    if ([note.name isEqualToString:@"QZBNeedUpdateMainScreen"]) {
        [self reloadTopicsData];
    }
}

- (void)reloadTopicsData {
    [[QZBServerManager sharedManager] GETTopicsForMainOnSuccess:^(NSDictionary *resultDict) {

        //         @{@"favorite_topics":faveTopics,
        //           @"friends_favorite_topics":friendsFaveTopics,
        //           @"featured_topics":featuredTopics,
        //           @"challenges":challenges
        //           };

        [self.refreshControl endRefreshing];

        self.roomArray = resultDict[@"rooms"];

        if ([resultDict[@"favorite_topics"] count] > 0) {
            self.faveTopics = resultDict[@"favorite_topics"];
        } else {
            self.faveTopics = nil;
        }
        
        if([resultDict[@"recent_topics"] count] > 0){
            self.recent = resultDict[@"recent_topics"];
        } else {
            self.recent = nil;
        }

        if ([resultDict[@"friends_favorite_topics"] count] > 0) {
            self.friendsTopics = resultDict[@"friends_favorite_topics"];
        } else {
            self.friendsTopics = nil;
        }

        if ([resultDict[@"featured_topics"] count] > 0) {
            self.featured = resultDict[@"featured_topics"];
        } else {
            self.featured = nil;
        }

        if ([resultDict[@"random_topics"] count] > 0) {
            self.additionalTopics = resultDict[@"random_topics"];
        } else {
            self.additionalTopics = nil;
        }

        if ([resultDict[@"challenges"] count] > 0) {
            self.challenges = [resultDict[@"challenges"] mutableCopy];
        } else {
            self.challenges = nil;
        }

        if ([resultDict[@"challenged"] count] > 0) {
            self.challenged = [resultDict[@"challenged"] mutableCopy];
        } else {
            self.challenged = nil;
        }

        if ([resultDict[@"room_invites"] count] > 0) {
            self.roomsIvites = [resultDict[@"room_invites"] mutableCopy];
        } else {
            self.roomsIvites = nil;
        }

        [self.workArray removeAllObjects];

        if (self.challenges.count > 0) {
            [self.workArray addObject:self.challenges];
        }

        if (self.challenged.count > 0) {
            [self.workArray addObject:self.challenged];
        }

        if (self.roomsIvites.count > 0) {
            [self.workArray addObject:self.roomsIvites];
        }

        [self.workArray addObject:self.roomArray];

        if (self.featured.count > 0) {
            [self.workArray addObject:self.featured];
        }
        
        if(self.recent.count > 0) {
            [self.workArray addObject:self.recent];
        }

        if (self.friendsTopics.count > 0) {
            [self.workArray addObject:self.friendsTopics];
        }

        if (self.faveTopics.count > 0) {
            [self.workArray addObject:self.faveTopics];
        }

        if (self.additionalTopics.count > 0) {
            [self.workArray addObject:self.additionalTopics];
        }

        [self.mainTableView reloadData];
        //  //   //   UITabBarController *tabController = self.tabBarController;
        //  //   //   UITabBarItem *tabbarItem = tabController.tabBar.items[2];

    } onFailure:^(NSError *error, NSInteger statusCode) {
        [self.refreshControl endRefreshing];
        UITabBarController *tabController = self.tabBarController;
        UITabBarItem *tabbarItem = tabController.tabBar.items[2];
        tabbarItem.badgeValue = nil;

        if (statusCode != -1) {
            [SVProgressHUD showErrorWithStatus:QZBNoInternetConnectionMessage];
        }
    }];
}

- (NSInteger)allCount {
    NSInteger count = 0;
    for (NSArray *arr in self.workArray) {
        count += arr.count;
    }
    return count;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - support methods

- (void)addBarButtonRight {
    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Комнаты"
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(showNewQuestionController)];
}

- (void)showNewQuestionController {
    
    [self performSegueWithIdentifier:QZBNewQuestionControllerSegueIdentifier sender:nil];
}

@end
