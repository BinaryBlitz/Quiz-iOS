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
#import "QZBGameTopic.h"
#import "QZBProgressViewController.h"
#import "UIView+QZBShakeExtension.h"
#import "NSObject+QZBSpecialCategory.h"

@interface QZBMainGameScreenTVC ()

@property (strong, nonatomic) NSArray *faveTopics;
@property (strong, nonatomic) NSArray *friendsTopics;
@property (strong, nonatomic) NSArray *featured;
@property (strong, nonatomic) NSMutableArray *challenges;
@property (strong, nonatomic) NSMutableArray *workArray;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) QZBChallengeDescription *challengeDescription;

@end

@implementation QZBMainGameScreenTVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    self.mainTableView.backgroundColor = [UIColor ultralightGreenColor];

    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(reloadTopicsData)
                  forControlEvents:UIControlEventValueChanged];

    [self.mainTableView addSubview:self.refreshControl];

   

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

    self.title = @"iQuiz";  // REDO

    [self initStatusbarWithColor:[UIColor blackColor]];
    
   // [self.refreshControl beginRefreshing];

    [self reloadTopicsData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showPreparingVC"] && self.challengeDescription) {
        QZBProgressViewController *destinationController = segue.destinationViewController;

        [destinationController initSessionWithDescription:self.challengeDescription];

        self.challengeDescription = nil;

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

    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *arr = self.workArray[indexPath.section];

    if ([arr isEqualToArray:self.challenges]) {
        QZBChallengeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"challengeCell"];
        cell.backgroundColor = [self colorForSection:indexPath.section];

        QZBChallengeDescription *descr = arr[indexPath.row];

        cell.topicNameLabel.text = descr.topicName;
        cell.opponentNameLabel.text = descr.name;

        return cell;

    } else {
        QZBTopicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"topicCell"];

        // NSArray *arr = self.workArray[indexPath.section];

        QZBGameTopic *topic = arr[indexPath.row];

        cell.backgroundColor = [self colorForSection:indexPath.section];

        NSInteger level = 0;
        float progress = 0.0;

        [NSObject calculateLevel:&level
                   levelProgress:&progress
                       fromScore:[topic.points integerValue]];

        [cell initCircularProgressWithLevel:level
                                   progress:progress
                                    visible:[topic.visible boolValue]];

        cell.topicName.text = topic.name;

        return cell;
    }
}

- (UIColor *)colorForSection:(NSInteger)section {
    UIColor *color = [UIColor blackColor];

    NSArray *arr = self.workArray[section];

    if ([arr isEqualToArray:self.faveTopics]) {
        color = [UIColor ultralightGreenColor];
    } else if ([arr isEqualToArray:self.friendsTopics]) {
        color = [UIColor lightCyanColor];

    } else if ([arr isEqualToArray:self.featured]) {
        color = [UIColor lightPincColor];

    } else if ([arr isEqualToArray:self.challenges]) {
        color = [UIColor lightGreenColor];
    }

    return color;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.reuseIdentifier isEqualToString:@"mainChallengeCell"]) {
        [self performSegueWithIdentifier:@"showChallenges" sender:nil];
    } else if ([cell.reuseIdentifier isEqualToString:@"mainDescriptionCell"]) {
        return;

    } else {
        // NSIndexPath *newIP = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0];

        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#(NSString *)#>

    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    // CGRect rect = CGRectMake(0, 0,CGRectGetWidth(tableView.frame), 48);

    UIView *view = [[UIView alloc] init];

    view.backgroundColor = [self colorForSection:section];

    CGRect rect = CGRectMake(0, 7, CGRectGetWidth(tableView.frame), 42);

    UILabel *label = [[UILabel alloc] initWithFrame:rect];

    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:18];

    if (section > 0) {
        [view addDropShadowsForView];
    }

    [view addSubview:label];

    NSString *text = @"";
    NSArray *arr = self.workArray[section];

    if ([arr isEqualToArray:self.faveTopics]) {
        text = @"Любимые топики";
    } else if ([arr isEqualToArray:self.friendsTopics]) {
        text = @"Популярное у друзей";

    } else if ([arr isEqualToArray:self.featured]) {
        text = @"Популярные темы";

    } else if ([arr isEqualToArray:self.challenges]) {
        text = @"Брошенные вызовы";
    }

    //[text uppercaseString];
    label.text = [text uppercaseString];

    return view;
}
#pragma mark - actions

- (IBAction)playGameAction:(id)sender {
    UITableViewCell *cell = [self parentCellForView:sender];

    if (cell) {
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

        // NSNumber *lobbyNumber = description.lobbyID;
        
        

        self.challengeDescription = description;
        
        self.choosedIndexPath = nil;
        [self.topicTableView beginUpdates];
        [self.topicTableView endUpdates];

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

        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
                           [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                       });
        
        self.choosedIndexPath = nil;

        [self.mainTableView beginUpdates];

        [self.mainTableView deleteRowsAtIndexPaths:@[ ip ]
                                  withRowAnimation:UITableViewRowAnimationRight];
        [self.challenges removeObjectAtIndex:ip.row];

        if (self.challenges.count == 0) {
            NSUInteger numInWorkArray = [self.workArray indexOfObject:self.challenges];
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:numInWorkArray];
            [self.mainTableView deleteSections:indexSet
                              withRowAnimation:UITableViewRowAnimationRight];
            [self.workArray removeObject:self.challenges];
        }

        //[arr removeObjectAtIndex:ip.row];

        [self.mainTableView endUpdates];

        [[QZBServerManager sharedManager] POSTDeclineChallengeWhithLobbyID:lobbyNumber
            onSuccess:^{

            }
            onFailure:^(NSError *error, NSInteger statusCode){

            }];
    }
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

        self.faveTopics = resultDict[@"favorite_topics"];
        self.friendsTopics = resultDict[@"friends_favorite_topics"];
        self.featured = resultDict[@"featured_topics"];

        NSArray *challArr = resultDict[@"challenges"];

        self.challenges = [challArr mutableCopy];

        [self.workArray removeAllObjects];

        if (self.challenges.count > 0) {
            [self.workArray addObject:self.challenges];
        }

        if (self.featured.count > 0) {
            [self.workArray addObject:self.featured];
        }

        if (self.friendsTopics.count > 0) {
            [self.workArray addObject:self.friendsTopics];
        }

        if (self.faveTopics.count > 0) {
            [self.workArray addObject:self.faveTopics];
        }

        [self.mainTableView reloadData];
        UITabBarController *tabController = self.tabBarController;
        UITabBarItem *tabbarItem = tabController.tabBar.items[0];
        tabbarItem.badgeValue = nil;
    } onFailure:^(NSError *error, NSInteger statusCode) {
        [self.refreshControl endRefreshing];
        UITabBarController *tabController = self.tabBarController;
        UITabBarItem *tabbarItem = tabController.tabBar.items[0];
        tabbarItem.badgeValue = nil;
        NSLog(@"status code %ld", (long)statusCode);
        if (statusCode != -1) {
            [SVProgressHUD showErrorWithStatus:QZBNoInternetConnectionMessage];
        }

    }];

    // self.tabBarItem.badgeValue = nil;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
