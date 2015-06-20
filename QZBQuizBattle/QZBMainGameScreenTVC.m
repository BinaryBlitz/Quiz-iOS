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
#import "QZBDescriptionCell.h"    //mainDescriptionCell
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
#import "UIFont+QZBCustomFont.h"
//#import "UIViewController+QZBMessagerCategory.h"

@interface QZBMainGameScreenTVC ()

@property (strong, nonatomic) NSArray *faveTopics;
@property (strong, nonatomic) NSArray *friendsTopics;
@property (strong, nonatomic) NSArray *featured;
@property (strong, nonatomic) NSArray *additionalTopics;
@property (strong, nonatomic) NSMutableArray *challenges;
@property (strong, nonatomic) NSMutableArray *challenged;
@property (strong, nonatomic) NSMutableArray *workArray;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) QZBChallengeDescription *challengeDescription;
@property (strong, nonatomic) QZBChallengeDescriptionWithResults *challengeDescriptionWithResults;


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

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
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
        
    }else if ([segue.identifier isEqualToString:@"showSessionResult"] &&
              self.challengeDescriptionWithResults){
        
        QZBEndGameVC *destinationVC = segue.destinationViewController;
        
        [destinationVC initWithChallengeResult:self.challengeDescriptionWithResults];
        self.challengeDescriptionWithResults = nil;
    }else {
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
       // cell.visible = descr.topic.visible;

        return cell;

    }else if([arr isEqualToArray:self.challenged]){
        QZBResultOfSessionCell *cell = [tableView
                                        dequeueReusableCellWithIdentifier:@"resultSessionCell"];
        
        QZBChallengeDescriptionWithResults *descr = self.challenged[indexPath.row];
        
        cell.backgroundColor = [self colorForSection:indexPath.section];
        cell.topicNameLabel.text = descr.topic.name;
        cell.opponentNameLabel.text =[NSString stringWithFormat:@"%@ (%@)",descr.opponentUser.name, descr.sessionResult];
        
        return cell;
        
    }else {
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

- (UIColor *)colorForSection:(NSInteger)section {//test
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
    } else if( arr == self.additionalTopics){
        
    }else if (arr == self.challenged){
        color = [UIColor strongGreenColor];
    }

    return color;
}

-(NSString *)textForArray:(NSArray *)arr{//test

    NSString *text = @"";
    
    
    if (arr==self.faveTopics) {
        text = @"Любимые темы";
        
    } else if (arr == self.friendsTopics) {
        text = @"Популярное у друзей";
        
    } else if (arr ==self.featured) {
        text = @"Популярные темы";
        
    } else if (arr == self.challenges) {
        text = @"Брошенные вызовы";
    } else if (arr == self.additionalTopics){
        
        text = @"Сыграйте эти темы";
    } else if (arr == self.challenged){
        text = @"Результаты";
    }
    return text;
    
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.reuseIdentifier isEqualToString:@"mainChallengeCell"]) {
        [self performSegueWithIdentifier:@"showChallenges" sender:nil];
    } else if ([cell.reuseIdentifier isEqualToString:@"mainDescriptionCell"]) {
        return;

    } else {


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
    label.font = [UIFont boldMuseoFontOfSize:20];

    if (section > 0) {
        [view addDropShadowsForView];
    }

    [view addSubview:label];

    NSArray *arr = self.workArray[section];

    label.text = [[self textForArray:arr] uppercaseString];

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

        //self.challengeDescription = description;
        
        self.choosedIndexPath = nil;
        [self.topicTableView beginUpdates];
        [self.topicTableView endUpdates];
        
        
        if(![description.topic.visible boolValue]){
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

        [self deleteRowWithAnimationOnIdexPath:ip
                                         array:self.challenges];

        [[QZBServerManager sharedManager] POSTDeclineChallengeWhithLobbyID:lobbyNumber
            onSuccess:^{}
            onFailure:^(NSError *error, NSInteger statusCode){}];
    }
}

- (IBAction)showChallengeResultActrion:(UIButton *)sender {
    
    
    UITableViewCell *cell = [self parentCellForView:sender];
    
    if (cell) {
        
        NSIndexPath *ip = [self.mainTableView indexPathForCell:cell];
        
        NSMutableArray *arr = self.workArray[ip.section];
        
        QZBChallengeDescriptionWithResults *description = arr[ip.row];
        
        //self.challengeDescription = description;
        
        self.choosedIndexPath = nil;
        [self.topicTableView beginUpdates];
        [self.topicTableView endUpdates];
        
        self.challengeDescriptionWithResults = description;
        
        [self performSegueWithIdentifier:@"showSessionResult" sender:nil];
        
        
        
    }
    
    
}

- (IBAction)hideChallengeResultAction:(UIButton *)sender {
    UITableViewCell *cell = [self parentCellForView:sender];
    if (cell) {
        NSIndexPath *ip = [self.mainTableView indexPathForCell:cell];
        NSMutableArray *arr = self.workArray[ip.section];
        QZBChallengeDescriptionWithResults *description =
        arr[ip.row];
        [self ignoreInteractions];
        
        self.choosedIndexPath = nil;
        
        [self deleteRowWithAnimationOnIdexPath:ip
                                         array:self.challenged];
        
        [[QZBServerManager sharedManager]DELETELobbiesWithID:description.lobbyID
                                                   onSuccess:nil
                                                   onFailure:nil];
        
    }
    
}


-(void)showRoomsList{
    [self performSegueWithIdentifier:@"showRoomList" sender:nil];
    
}

-(void)ignoreInteractions{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                   });
}

-(void)deleteRowWithAnimationOnIdexPath:(NSIndexPath *)ip array:(NSMutableArray *)arr{
    
    [self.mainTableView beginUpdates];
    
    [self.mainTableView deleteRowsAtIndexPaths:@[ ip ]
                              withRowAnimation:UITableViewRowAnimationRight];
    [arr removeObjectAtIndex:ip.row];
    
    if (arr.count == 0) {
        NSUInteger numInWorkArray = [self.workArray indexOfObject:arr];
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:numInWorkArray];
        [self.mainTableView deleteSections:indexSet
                          withRowAnimation:UITableViewRowAnimationRight];
        [self.workArray removeObject:arr];
    }
    
    [self.mainTableView endUpdates];
    
    
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
        self.additionalTopics = resultDict[@"random_topics"];

        NSArray *challArr = resultDict[@"challenges"];
    

        self.challenges = [challArr mutableCopy];
        self.challenged = [resultDict[@"challenged"] mutableCopy];

        [self.workArray removeAllObjects];

        if (self.challenges.count > 0) {
            [self.workArray addObject:self.challenges];
        }
        
        if(self.challenged.count > 0){
            [self.workArray addObject:self.challenged];
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
        
        if(self.additionalTopics.count>0){
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


//-(NSArray *)getAlladditionalTopics{
//    NSArray *allTopics = [QZBGameTopic MR_findAllSortedBy:@"points" ascending:YES];
//    
//    if(allTopics && allTopics.count>0){
//        NSInteger length = 0;
//        
//        NSInteger allC = [self allCount];
//        
//        if(allC>=9){
//            length = 3;
//        }else{
//            length = 12-allC;
//        }
//        
//        
//        if(length>allTopics.count){
//            length = allTopics.count;
//        }
//        
//        NSRange r = {.location = 0, .length = length};
//        
//        
//        NSArray *additionalArr = [allTopics subarrayWithRange:r];
//        
//        return [NSArray arrayWithArray:additionalArr];
//        
//    }else{
//        return nil;
//    }
//
//    
//}

-(NSInteger)allCount{
    NSInteger count = 0;
    for(NSArray *arr in self.workArray){
        count+=arr.count;
    }
    return count;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - support methods

-(void)addBarButtonRight{
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                  target:self
                                                  action:@selector(showRoomsList)];
    
    
}

@end
