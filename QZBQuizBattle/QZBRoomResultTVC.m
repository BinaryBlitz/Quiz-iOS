//
//  QZBRoomResultTVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 25/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRoomResultTVC.h"
#import "QZBRoomUserResultCell.h"
#import "QZBUserWithTopic.h"
#import "QZBRoom.h"
#import "QZBRoomWorker.h"
#import "QZBRoomOnlineWorker.h"
#import "QZBSessionManager.h"
#import "UIViewController+QZBControllerCategory.h"
#import "UIColor+QZBProjectColors.h"

#import "QZBCategory.h"
#import "QZBGameTopic.h"
#import "QZBTopicWorker.h"

//controllers
#import "QZBRoomListTVC.h"
#import "QZBRoomSessionResults.h"
#import "QZBQuestionReportTVC.h"


//dfiimage

#import <DFImageManager/DFImageManager.h>
#import <DFImageManager/DFImageRequestOptions.h>
#import <DFImageManager/DFURLImageFetcher.h>
#import <DFImageManager/DFImageRequest.h>
#import <DFImageManager/DFImageView.h>

#import <UAAppReviewManager.h>



//cell identifiers
NSString *const QZBRoomUserResultCellIdentifier = @"roomUserResultCellIdentifier";

//segue identifiers
NSString *const QZBShowQuestionsFromRoomIdentifier = @"showQuestionsFromRoomIdentifier";

@interface QZBRoomResultTVC()

//@property(strong, nonatomic) NSMutableArray *usersInResult;
//@property(strong, nonatomic) QZBRoom *room;
@property (strong, nonatomic) QZBRoomWorker *roomWorker;
@property (strong, nonatomic) NSNumber *roomSessionID;
@property (strong, nonatomic) NSArray *questions;
@property (strong, nonatomic) QZBGameTopic *topic;

@end

@implementation QZBRoomResultTVC


-(void)viewDidLoad{
    [super viewDidLoad];
    [self initStatusbarWithColor:[UIColor blackColor]];
    self.title = @"Результаты";
    [UAAppReviewManager userDidSignificantEvent:YES];
    [self configureBackgroundImage];
    [self backButtonInit];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self
                            action:@selector(reloadRoom)
                  forControlEvents:UIControlEventValueChanged];
    self.refreshControl.tintColor = [UIColor whiteColor];
    
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    CGRect r = [UIScreen mainScreen].bounds;
    CGRect headerRect = CGRectMake(0, 0, r.size.width, r.size.height/3.0);
    
    UIView *header = [[UIView alloc] initWithFrame:headerRect];
    self.tableView.tableHeaderView = header;
    self.roomWorker = [QZBSessionManager sessionManager].roomWorker;
    
    // [self configureResultWithRoom:self.roomWorker.room];
    self.roomSessionID = [[QZBSessionManager sessionManager] sessionID];
    self.questions = [[QZBSessionManager sessionManager] sessionQuestions];
    self.topic = [QZBSessionManager sessionManager].topic;
    [[QZBSessionManager sessionManager] closeSession];
    [self addBarButtonRight];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(oneOfUsersFinishedRoom:)
                                                 name:QZBOneUserFinishedGameInRoom
                                               object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
//    self.roomWorker = [QZBSessionManager sessionManager].roomWorker;
//    
//   // [self configureResultWithRoom:self.roomWorker.room];
//    self.roomSessionID = [[QZBSessionManager sessionManager] sessionID];
//    self.questions = [[QZBSessionManager sessionManager] sessionQuestions];
//    self.topic = [QZBSessionManager sessionManager].topic;
//    [[QZBSessionManager sessionManager] closeSession];
//    [self addBarButtonRight];
    
    //[self reloadRoom];
//    NSInteger count = [self.tableView numberOfRowsInSection:0];
//    NSIndexPath *ip = [NSIndexPath indexPathForRow:count-1 inSection:0];
//    
//    [self.tableView scrollToRowAtIndexPath:ip
//                          atScrollPosition:UITableViewScrollPositionBottom
//                                  animated:YES];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(oneOfUsersFinishedRoom:)
//                                                 name:QZBOneUserFinishedGameInRoom
//                                               object:nil];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
  //  [UAAppReviewManager showPromptIfNecessary];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
//    [self.roomWorker closeOnlineWorker];
//    self.roomWorker = nil;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.roomWorker closeOnlineWorker];
    self.roomWorker = nil;
}

//- (void)configureResultWithRoom:(QZBRoom *)room {
//    self.room = room;
//    
//    [self.tableView reloadData];
//}

#pragma mark - navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:QZBShowQuestionsFromRoomIdentifier]) {
        QZBQuestionReportTVC *destVC = segue.destinationViewController;
        [destVC configureWithQuestions:self.questions topic:self.topic];
    }
}


#pragma mark - actions

-(void)leaveResults{
    
    NSArray *controllers = self.navigationController.viewControllers;
    UIViewController *destinationController = nil;
    
    for(UIViewController *c in controllers){
        if([c isKindOfClass:[QZBRoomListTVC class]]) {
            destinationController = c;
            break;
        }
    }
    if(destinationController){
        [self.navigationController popToViewController:destinationController
                                              animated:YES];
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.roomWorker.room.participants.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    QZBRoomUserResultCell *cell = [tableView dequeueReusableCellWithIdentifier:QZBRoomUserResultCellIdentifier];
    
    QZBUserWithTopic *userWithTopic = self.roomWorker.room.participants[indexPath.row];
    
    NSInteger position = indexPath.row + 1;
    
    [cell confirureWithUserWithTopic:userWithTopic position:@(position)];
    
    if(indexPath.row<3 && userWithTopic.finished){
        UIImage *cupImage = [[UIImage imageNamed:@"cupImage"]
                             imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIColor *color = [UIColor whiteColor];
        if(indexPath.row == 0){
            color = [UIColor goldColor];
            
        }else if(indexPath.row == 1){
            color = [UIColor silverColor];
        }else if (indexPath.row == 2){
            color = [UIColor bronzeColor];
        }
        cell.cupImageView.tintColor = color;
        cell.cupImageView.image = cupImage;
    } else{
        cell.cupImageView.image = nil;
    }
    
    return cell;
    
}

#pragma mark - UITableViewDelegate

#pragma mark - support methods

-(void)configureBackgroundImage {
    
    QZBGameTopic *topic = [QZBSessionManager sessionManager].topic;
    
    QZBCategory *category = [QZBTopicWorker tryFindRelatedCategoryToTopic:topic];
    if (category) {
        NSURL *url = [NSURL URLWithString:category.background_url];
        
        CGRect r = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds),
                              16 * CGRectGetWidth([UIScreen mainScreen].bounds) / 9);
        
        DFImageView *dfiIV = [[DFImageView alloc] initWithFrame:r];
        
        self.tableView.backgroundColor = [UIColor clearColor];
        
        DFImageRequestOptions *options = [DFImageRequestOptions new];
        options.allowsClipping = YES;
        
        options.userInfo = @{ DFURLRequestCachePolicyKey :
                                  @(NSURLRequestReturnCacheDataElseLoad)};
        //options.expirationAge = 60*60*24*10;
        
        DFImageRequest *request = [DFImageRequest requestWithResource:url
                                                           targetSize:CGSizeZero
                                                          contentMode:DFImageContentModeAspectFill
                                                              options:options];
        
        dfiIV.allowsAnimations = NO;
        dfiIV.allowsAutoRetries = YES;
        
        [dfiIV prepareForReuse];
        
        [dfiIV setImageWithRequest:request];
        
        UIView *backV = [[UIView alloc] init];
        backV.backgroundColor = [UIColor blackColor];
        //[backV addSubview:dfiIV];
        UIView *frontV = [[UIView alloc] initWithFrame:r];
        
        frontV.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.7];
        
        [backV addSubview:frontV];
        [backV insertSubview:dfiIV belowSubview:frontV];
        
        self.tableView.backgroundView = backV;
    }
}

- (void)backButtonInit {
    //   UIBarButtonItem *bbItem = [UIBarButtonItem alloc] initWithCustomView:
    UIBarButtonItem *logoutButton =
    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cancelCross"]
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(leaveResults)];
    
    self.navigationItem.leftBarButtonItem = logoutButton;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void)reloadRoom {
//    [self.refreshControl beginRefreshing];
//    [[QZBServerManager sharedManager] GETRoomWithID:self.roomWorker.room.roomID
//                                          OnSuccess:^(QZBRoom *room) {
//        
//        [self.refreshControl endRefreshing];
//        self.roomWorker.room = room;
//                                              
//                                              [self.tableView reloadData];
//    } onFailure:^(NSError *error, NSInteger statusCode) {
//        [self.refreshControl endRefreshing];
//        
//    }];
//
    if(self.roomSessionID){
        [self.refreshControl beginRefreshing];
            [[QZBServerManager sharedManager] GETRoomWithID:self.roomWorker.room.roomID
                                                  OnSuccess:^(QZBRoom *room) {
                                                      
            [[QZBServerManager sharedManager] GETResultsOfRoomSessionWithID:self.roomSessionID
                                      onSuccess:^(QZBRoomSessionResults *sessionResults) {
                                          
            for(QZBUserWithTopic *userWithTopic in room.participants) {
                id<QZBUserProtocol> us = userWithTopic.user;
                if([sessionResults pointsForUserWithID:us.userID]) {
                    userWithTopic.points = [sessionResults pointsForUserWithID:us.userID];
                }
             }
                                        
                                          self.roomWorker.room = room;
                                          
                                          [self.roomWorker sortUsers];
                                          
                                          [self.tableView reloadData];
                                                  [self.refreshControl endRefreshing];
                            } onFailure:^(NSError *error, NSInteger statusCode) {
                            [self.refreshControl endRefreshing];
                            }];
                                                      
                                                      
        
                                                      
                                                     // [self.tableView reloadData];
            } onFailure:^(NSError *error, NSInteger statusCode) {
                [self.refreshControl endRefreshing];
                
            }];
    }
    
//    [[QZBServerManager sharedManager] GETResultsOfRoomSessionWithID:self.roomSessionID
//                                                          onSuccess:^(QZBRoomSessionResults *sessionResults) {
//                                                              [self.refreshControl endRefreshing];
//    } onFailure:^(NSError *error, NSInteger statusCode) {
//        [self.refreshControl endRefreshing];
//    }];
//    }
    
}


#pragma mark - results


-(void)oneOfUsersFinishedRoom:(NSNotification *)note {
    if(note && [note.name isEqualToString:QZBOneUserFinishedGameInRoom]) {
//        NSDictionary *d = note.object;
//        
//        NSNumber *userID = d[@"player_id"];
//        NSNumber *points = d[@"points"];
//        
//        [self.roomWorker userWithId:userID resultPoints:points];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
       // [self.tableView reloadData];
    }
}


-(void)addBarButtonRight {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Вопросы"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(showReportScreen)];
}

-(void)showReportScreen {
    [self performSegueWithIdentifier:QZBShowQuestionsFromRoomIdentifier sender:nil];
}

@end
