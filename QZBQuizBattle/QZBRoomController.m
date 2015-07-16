//
//  QZBRoomController.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 16/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRoomController.h"
#import "QZBRoom.h"
#import "QZBRoomWorker.h"
#import "QZBGameTopic.h"
#import "QZBUserWithTopic.h"
#import "QZBAnotherUser.h"
#import "UIViewController+QZBControllerCategory.h"
#import "QZBCurrentUser.h"

#import "QZBEnterRoomCell.h"
#import "QZBUserInRoomCell.h"

#import "QZBServerManager.h"

#import "QZBSessionManager.h"

//room worker

#import "QZBRoomOnlineWorker.h"

//ui

#import <SVProgressHUD.h>



// cells
NSString *const QZBUserInRoomCellIdentifier = @"userInRoomCellIdentifier";
NSString *const QZBEnterRoomCellIdentifier  = @"enterRoomCellIdentifier";

// segues
NSString *const QZBShowRoomCategoryChooser  = @"showRoomCategoryChooser";
NSString *const QZBShowGameController       = @"showGameController";

//message

NSString *const QZBNoRoomErrMessage = @"Комната была удалена";
NSString *const QZBStartSessionProblems = @"Что-то пошло не так";

// lastButtonStateEnum
typedef NS_ENUM(NSInteger, QZBRoomState) {
    QZBRoomStateWaitingPlayers,
    QZBRoomStateCanStartGame,
    QZBRoomStateWaitStartGame,
    QZBRoomStateChooseAndJoin,
    QZBRoomStateIsNotReady,
    QZBRoomStateAlreadyReady,
    QZBRoomStateNone
};

@interface QZBRoomController () <UIAlertViewDelegate>

@property (strong, nonatomic) QZBRoom *room;

@property (strong, nonatomic) QZBRoomWorker *roomWorker;

@property (assign, nonatomic) BOOL isLeaveRoom;

@property (assign, nonatomic) BOOL isStarted;
//@property (strong, nonatomic) QZBRoomOnlineWorker *onlineWorker;
//@property (strong, nonatomic) QZBGameTopic *selectedTopic;
//@property (strong, nonatomic) QZBUserWithTopic *currentUserWithTopic;

@end

@implementation QZBRoomController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self
                            action:@selector(reloadRoom)
                  forControlEvents:UIControlEventValueChanged];
    self.refreshControl.tintColor = [UIColor whiteColor];
    
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self reloadRoom];

    //  self.usersWithTopics = [NSMutableArray array];
    // [self initStatusbarWithColor:[UIColor blackColor]];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initStatusbarWithColor:[UIColor blackColor]];

    [self backButtonInit];
   // [self reloadRoom];
    
    // self.tabBarController.tabBar.hidden = YES;
  //  [self.navigationController setToolbarHidden:NO animated:YES];
  //  self.tabBarController.tabBar.hidden = YES;
    
   // self.to
   //  [self.navigationController setToolbarHidden:YES animated:YES];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(leaveOrDeleteRoom)
//                                                 name:UIApplicationDidEnterBackgroundNotification
//                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(leaveOrDeleteRoom)
//                                                 name:UIApplicationWillTerminateNotification
//                                               object:nil];
    
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
  //  self.tabBarController.tabBar.hidden = NO;
    [self.navigationController setToolbarHidden:YES animated:YES];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    [self leaveOrDeleteRoom];
     self.tabBarController.tabBar.hidden = NO;
    
}

- (void)initWithRoom:(QZBRoom *)room {
    self.room = room;
    
    if([self isOwner]){
        [self generateRoomWorkerWithRoom:self.room];
    }

    [self setTitleWithRoom:room];
}

#pragma mark - actions

- (void)leaveCurrentRoom {
    QZBUser *user = [QZBCurrentUser sharedInstance].user;
    
    
    
    if (!self.room ||![self.room isContainUser:user]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Покинуть комнату"
                                    message:@"Вы уверены?"
                                   delegate:self
                          cancelButtonTitle:@"Нет"
                          otherButtonTitles:@"Да", nil] show];
    }
}

- (void)leaveOrDeleteRoom {
    if (self.roomWorker) {
     //   [self.roomWorker closeOnlineWorker];
        
        
        if ([self isOwner]) {
            [[QZBServerManager sharedManager] DELETEDeleteRoomWithID:self.room.roomID
                onSuccess:^{

                }
                onFailure:^(NSError *error, NSInteger statusCode){

                }];
        } else {
            [[QZBServerManager sharedManager] DELETELeaveRoomWithID:self.room.roomID
                onSuccess:^{

                }
                onFailure:^(NSError *error, NSInteger statusCode){

                }];
        }
        

    }
}

-(void)leaveDeletedRoom {
    if(!self.isLeaveRoom){
        self.isLeaveRoom = YES;
        [self.roomWorker closeOnlineWorker];
        self.roomWorker = nil;
        self.room = nil;
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)startGame {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[QZBServerManager sharedManager] POSTStartRoomWithID:self.room.roomID onSuccess:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(!self.isStarted){
            [SVProgressHUD showErrorWithStatus:QZBStartSessionProblems];
            }
        });
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        [SVProgressHUD showErrorWithStatus:QZBNoInternetConnectionMessage];
        
    }];
}


#pragma mark - Navigation


//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if([segue.identifier isEqualToString:QZBShowGameController]){
//        
//    }
//}

//-(void)didMoveToParentViewController:(UIViewController *)parent{
//
//
//    NSLog(@"popped");
//
//}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger count = self.room.participants.count;
    // if(self.shouldShowEnterRoomCell){
    count++;
    //}
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [tableView numberOfRowsInSection:0] - 1) {
        QZBUserInRoomCell *cell =
            [tableView dequeueReusableCellWithIdentifier:QZBUserInRoomCellIdentifier];

        QZBUserWithTopic *userWithTopic = self.room.participants[indexPath.row];

        [cell configureCellWithUserWithTopic:userWithTopic];
        return cell;
    } else {
        QZBEnterRoomCell *cell =
            [tableView dequeueReusableCellWithIdentifier:QZBEnterRoomCellIdentifier];
        cell.enterRoomLabel.text = [self stringForCurrentState];

        return cell;
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UITableViewDelegate

- (void)showCategoryChooser {
    [self performSegueWithIdentifier:QZBShowRoomCategoryChooser sender:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    if ([cell isKindOfClass:[QZBEnterRoomCell class]]) {
        QZBRoomState roomState = [self roomState];

        if ([self canPressLastButton]){
            if(roomState == QZBRoomStateChooseAndJoin){
                [self performSegueWithIdentifier:QZBShowRoomCategoryChooser sender:nil];
            } else if (roomState == QZBRoomStateIsNotReady){
                [self makeCurrentUserReady:YES];
            }else {
                [self startGame];
            }
        }
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90.0;
}

#pragma mark - setting room



- (void)setUserTopic:(QZBGameTopic *)topic {
        [[QZBServerManager sharedManager] POSTJoinRoomWithID:self.room.roomID
            withTopic:topic
            onSuccess:^{
              //  [self addUserInRoomWithTopic:topic];
                [self generateRoomWorkerWithRoom:self.room];
                [self reloadRoom];
                [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeNone];
            }
            onFailure:^(NSError *error, NSInteger statusCode){

                
            }];
}

- (void)addUserInRoomWithTopic:(QZBGameTopic *)topic {
   // self.selectedTopic = topic;
    QZBUser *u = [QZBCurrentUser sharedInstance].user;
    QZBUserWithTopic *uAndT = [[QZBUserWithTopic alloc] initWithUser:u topic:topic];

    //self.currentUserWithTopic = uAndT;

    [self.room addUser:uAndT];
    //  [self.usersWithTopics addObject:uAndT];
    [self.tableView reloadData];
}


-(void)reloadRoom{
    
    
    [self.refreshControl beginRefreshing];
    [[QZBServerManager sharedManager] GETRoomWithID:self.room.roomID OnSuccess:^(QZBRoom *room) {
        [self.refreshControl endRefreshing];
        self.room = room;
        self.roomWorker.room = self.room;
        
        NSLog(@"room %@ roomworker %@",self.room, self.roomWorker.room);
        [self.tableView reloadData];
        
        
        [SVProgressHUD dismiss];
    } onFailure:^(NSError *error, NSInteger statusCode) {
        [self.refreshControl endRefreshing];
        
        if(statusCode == 404){
            [SVProgressHUD showErrorWithStatus:QZBNoRoomErrMessage];
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [self leaveDeletedRoom];
                [[UIApplication sharedApplication]
                 endIgnoringInteractionEvents];
             //   [self.navigationController popViewControllerAnimated:YES];
                
            });
        }
       // [SVProgressHUD dismiss];
        
    }];
}

-(void)generateRoomWorkerWithRoom:(QZBRoom *)room {
    self.roomWorker = [[QZBRoomWorker alloc] initWithRoom:room];

    [self.roomWorker addRoomOnlineWorker];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showGameController)
                                                 name:QZBNeedStartRoomGame
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadRoom)
                                                 name:QZBNewParticipantJoinedRoom
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadRoom)
                                                 name:QZBOneOfUserLeftRoom
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadRoom)
                                                 name:QZBOneUserChangedStatus
                                               object:nil];
    
}

-(void)showGameController{
    
    [SVProgressHUD dismiss];
    self.isStarted = YES;
    
    QZBGameTopic *topic = self.room.owner.topic;
    
    [[QZBSessionManager sessionManager] setTopicForSession:topic];
    [[QZBSessionManager sessionManager] setRoomWorkerToSessionWorker:self.roomWorker];
    
    self.roomWorker = nil;
    [self performSegueWithIdentifier:QZBShowGameController sender:nil];
}


#pragma mark - support methods

- (BOOL)shouldShowEnterRoomCell {
    return YES;
}

- (BOOL)isOwner {
    // return YES;

    if (!self.room) {
        return YES;
    }

    NSNumber *currentUserID = [QZBCurrentUser sharedInstance].user.userID;
    NSNumber *ownerUserID = self.room.owner.user.userID;

    return [currentUserID isEqualToNumber:ownerUserID];
    
   // // // return YES;
}

- (QZBRoomState)roomState {
    //    if([self isOwner] && !self.room){
    //        return @"Выбрать тему и создать комнату";
    //    }else if (<#expression#>)

    
    QZBUserWithTopic *userWithTopic = [self.room findUser:[QZBCurrentUser sharedInstance].user];
    if ([self isOwner]) {
        if (userWithTopic && !userWithTopic.isReady){
            return QZBRoomStateIsNotReady;
        }else if (self.room.participants.count < 2) {
            return QZBRoomStateWaitingPlayers;
        } else {
            return QZBRoomStateCanStartGame;
        }
    } else {
        QZBUser *user = [QZBCurrentUser sharedInstance].user;
        if (![self.room isContainUser:user]) {
            return QZBRoomStateChooseAndJoin;
        } else if (userWithTopic && !userWithTopic.isReady){
            return  QZBRoomStateIsNotReady;
        }else if (self.room.participants.count < 2) {
            return QZBRoomStateWaitingPlayers;
        } else {
            return QZBRoomStateWaitingPlayers;
        }
    }
}

- (NSString *)stringForState:(QZBRoomState)roomState {
    switch (roomState) {
        case QZBRoomStateCanStartGame:
            return @"НАЧАТЬ ИГРУ";
            break;
        case QZBRoomStateWaitStartGame:
            return @"ЖДЕМ НАЧАЛА ИГРЫ";
            break;
        case QZBRoomStateChooseAndJoin:
            return @"+ ЗАНЯТЬ МЕСТО";
            break;
        case QZBRoomStateWaitingPlayers:
            return @"ЖДЕМ ИГРОКОВ";
            break;
        case QZBRoomStateNone:
            return @"";
            break;
        case QZBRoomStateIsNotReady:
            return @"ПОДТВЕРТИЬ ГОТОВНОСТЬ!";
        default:
            return @"";
            break;
    }
}

- (BOOL)canPressLastButton {
    QZBRoomState roomState = [self roomState];
    if (roomState == QZBRoomStateChooseAndJoin ||
        roomState == QZBRoomStateCanStartGame || roomState == QZBRoomStateIsNotReady) {
        return YES;
    } else {
        return NO;
    }
}

- (NSString *)stringForCurrentState {
    QZBRoomState s = [self roomState];

    return [self stringForState:s];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void)setTitleWithRoom:(QZBRoom *)room{
    
    NSString *title = nil;
    if(self.room){
        title = [NSString stringWithFormat:@"Комната %@", room.roomID];
    } else {
        title = [NSString stringWithFormat:@"Новая комната"];
    }
    
    self.title = title;
}

-(void)makeCurrentUserReady:(BOOL)isReady {
    QZBUserWithTopic *userWithTopic = [self.room findUser:[QZBCurrentUser sharedInstance].user];
    
    
    if(userWithTopic){
        
        NSInteger position = [self.room.participants indexOfObject:userWithTopic];
        
        NSIndexPath *ip = [NSIndexPath indexPathForRow:position inSection:0];
        
        QZBUserInRoomCell *userInRoomCell = (QZBUserInRoomCell *)[self.tableView cellForRowAtIndexPath:ip];
        
        userInRoomCell.isReadyLabel.hidden = YES;
        userInRoomCell.isReadyActivityIndicator.hidden = NO;
        [userInRoomCell.isReadyActivityIndicator startAnimating];
        
    [[QZBServerManager sharedManager] PATCHParticipationWithID:userWithTopic.userWithTopicID isReady:isReady onSuccess:^{
        userWithTopic.ready = isReady;
        userInRoomCell.isReadyLabel.hidden = NO;
        userInRoomCell.isReadyActivityIndicator.hidden = YES;
        [userInRoomCell.isReadyActivityIndicator stopAnimating];
        [self.tableView reloadData];
    } onFailure:^(NSError *error, NSInteger statusCode) {
        userInRoomCell.isReadyLabel.hidden = NO;
        userInRoomCell.isReadyActivityIndicator.hidden = YES;
        [userInRoomCell.isReadyActivityIndicator stopAnimating];
        [self.tableView reloadData];
    }];
    }
}


//-(QZBUserWithTopic *)current

#pragma mark - ui

- (void)backButtonInit {
    //   UIBarButtonItem *bbItem = [UIBarButtonItem alloc] initWithCustomView:
    UIBarButtonItem *logoutButton =
        [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cancelCross"]
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(leaveCurrentRoom)];

    self.navigationItem.leftBarButtonItem = logoutButton;
}

@end
