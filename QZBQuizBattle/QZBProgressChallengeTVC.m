//
//  QZBProgressChallengeTVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 18/03/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBProgressChallengeTVC.h"
#import "QZBServerManager.h"
#import "QZBChallengeCell.h"
#import "QZBChallengeDescription.h"
#import "QZBGameTopic.h"
//#import "QZBMainGameScreenTVC.h"
#import <SVProgressHUD/SVProgressHUD.h>


@interface QZBProgressChallengeTVC()

@property(strong, nonatomic) NSMutableArray *challengeDescriptions;
@property(assign, nonatomic) BOOL shouldEnable;
@property(strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation QZBProgressChallengeTVC

-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.shouldEnable = NO;
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(reloadTableView)
                  forControlEvents:UIControlEventValueChanged];
    
    [self.tableView addSubview:self.refreshControl];
    
    
    [[QZBServerManager sharedManager] GETThrownChallengesOnSuccess:^(NSArray *challenges) {
        
        self.challengeDescriptions = [NSMutableArray arrayWithArray: challenges];
        [self.tableView reloadData];
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
    }];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    UITabBarController *tabController = self.tabBarController;
    UITabBarItem *tabbarItem = tabController.tabBar.items[2];
    
    
    tabbarItem.badgeValue = nil;

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if (![parent isEqual:self.parentViewController]) {
        NSLog(@"Back pressed");
        [self closeFinding];
    }
}
-(void)initSession{
    NSLog(@"subclassed");
    self.shouldEnable = YES;
    [self.tableView reloadData];
    
}

#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.challengeDescriptions.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //return [[UITableViewCell alloc] init];
    QZBChallengeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"challengeCell"];
    
    
    QZBChallengeDescription *description = self.challengeDescriptions[indexPath.row];
    
    cell.opponentNameLabel.text = description.name;
    cell.topicNameLabel.text = [NSString stringWithFormat:@"%@",description.topicID];
    
    cell.acceptButton.enabled = self.shouldEnable;
    cell.declineButton.enabled = self.shouldEnable;
    return cell;
    
}

#pragma mark - actions

- (UITableViewCell *)parentCellForView:(id)theView {
    id viewSuperView = [theView superview];
    while (viewSuperView != nil) {
        if ([viewSuperView isKindOfClass:[UITableViewCell class]]) {
            return (UITableViewCell *)viewSuperView;
        } else {
            viewSuperView = [viewSuperView superview];
        }
    }
    return nil;
}

- (IBAction)acceptButtonAction:(UIButton *)sender {
    UITableViewCell *cell = [self parentCellForView:sender];
    if (cell != nil) {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        QZBChallengeDescription *description = self.challengeDescriptions[indexPath.row];
        NSNumber *lobbyNumber = description.lobbyID;
        
        [[QZBServerManager sharedManager] POSTAcceptChallengeWhithLobbyID:lobbyNumber onSuccess:^(QZBSession *session, QZBOpponentBot *bot) {
            
            [self settitingSession:session bot:bot];
            
        } onFailure:^(NSError *error, NSInteger statusCode) {
            [SVProgressHUD showErrorWithStatus:@"Проверьте подключение к интернету"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
        }];
        
        //[self performSegueWithIdentifier:@"showPreparingVC" sender:nil];
    }
}
- (IBAction)declineButtonAction:(UIButton *)sender {
    UITableViewCell *cell = [self parentCellForView:sender];
    if (cell != nil) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        QZBChallengeDescription *description = self.challengeDescriptions[indexPath.row];
        NSNumber *lobbyNumber = description.lobbyID;
        
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        });
        
        [self.tableView beginUpdates];
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        [self.challengeDescriptions removeObjectAtIndex:indexPath.row];
        
        
        [self.tableView endUpdates];
        
        
        [[QZBServerManager sharedManager] POSTDeclineChallengeWhithLobbyID:lobbyNumber onSuccess:^{
            
        } onFailure:^(NSError *error, NSInteger statusCode) {
            
        }];
        
      
        //[self performSegueWithIdentifier:@"showPreparingVC" sender:nil];
    }
}

-(void)reloadTableView{
    
    [self.refreshControl beginRefreshing];
    [[QZBServerManager sharedManager] GETThrownChallengesOnSuccess:^(NSArray *challenges) {
        
        self.challengeDescriptions = [NSMutableArray arrayWithArray: challenges];
        [self.tableView reloadData];
        
        [self.refreshControl endRefreshing];
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        [self.refreshControl endRefreshing];
        
        
    }];

}


@end
