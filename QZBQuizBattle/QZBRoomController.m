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

#import "QZBFriendsChooserRoomsController.h"

//room worker

#import "QZBRoomOnlineWorker.h"

//ui

#import <SVProgressHUD.h>
#import "UIFont+QZBCustomFont.h"

// cells
NSString *const QZBUserInRoomCellIdentifier = @"userInRoomCellIdentifier";
NSString *const QZBEnterRoomCellIdentifier  = @"enterRoomCellIdentifier";

// segues
NSString *const QZBShowRoomCategoryChooser  = @"showRoomCategoryChooser";
NSString *const QZBShowGameController       = @"showGameController";
NSString *const QZBShowFriendsChooserSegieIdentifier = @"showFriendsChooser";

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

const NSInteger QZBMinimumPlayersCountInRoom = 3;

@interface QZBRoomController () <UIAlertViewDelegate>

@property (strong, nonatomic) QZBRoom *room;

@property (strong, nonatomic) QZBRoomWorker *roomWorker;

@property (assign, nonatomic) BOOL isLeaveRoom;

@property (assign, nonatomic) BOOL isStarted;

@property(assign, nonatomic) BOOL needRemoveObserver;

@property (strong, nonatomic) UITapGestureRecognizer *isReadyGestureRecognizer;

@property(strong, nonatomic) UIView *bottomView;
//@property (strong, nonatomic) QZBRoomOnlineWorker *onlineWorker;
//@property (strong, nonatomic) QZBGameTopic *selectedTopic;
//@property (strong, nonatomic) QZBUserWithTopic *currentUserWithTopic;

@end

@implementation QZBRoomController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.hidesBottomBarWhenPushed = YES;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self
                            action:@selector(reloadRoom)
                  forControlEvents:UIControlEventValueChanged];
    self.refreshControl.tintColor = [UIColor whiteColor];
    
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 80, 0);
    [self reloadRoom];
    
    //[self.navigationController setToolbarHidden:NO animated:YES];
    self.isReadyGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                         action:@selector(userPressIsReadyButton:)];
    
    self.isReadyGestureRecognizer.numberOfTapsRequired = 1;
    self.isReadyGestureRecognizer.numberOfTouchesRequired = 1;

    //  self.usersWithTopics = [NSMutableArray array];
    // [self initStatusbarWithColor:[UIColor blackColor]];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    [self initStatusbarWithColor:[UIColor blackColor]];

    [self backButtonInit];
    
    //[self.navigationController setToolbarHidden:NO animated:YES];
   // self.automaticallyAdjustsScrollViewInsets = NO;
    
   // [self reloadRoom];
    
    // self.tabBarController.tabBar.hidden = YES;
  //  [self.navigationController setToolbarHidden:NO animated:YES];
  //  self.tabBarController.tabBar.hidden = YES;
    
   // self.to
    //[self.navigationController setToolbarHidden:YES animated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(leaveThisRoom)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(leaveThisRoom)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    //TODO закрытвать экран
    
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
  //  [self.navigationController.view addSubview:self.bottomView];
    
    if(self.roomWorker){
        [self animateUp];
    }
   // [self.navigationController setToolbarHidden:NO animated:YES];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self animateDown];
   // [self.bottomView removeFromSuperview];
  //  [self.navigationController setToolbarHidden:YES animated:YES];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if(self.needRemoveObserver){
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)dealloc {
    [self leaveOrDeleteRoom];
     self.tabBarController.tabBar.hidden = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initWithRoom:(QZBRoom *)room {
    self.room = room;
    
    if ([self isOwner]) {
        [self generateRoomWorkerWithRoom:self.room];
    }

    [self setTitleWithRoom:room];
}




#pragma mark - actions

- (void)leaveCurrentRoom {
    QZBUser *user = [QZBCurrentUser sharedInstance].user;
    
    
    
    if (!self.room ||![self.room isContainUser:user]) {
        self.needRemoveObserver = YES;
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
        
        self.needRemoveObserver = YES;
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


-(void)userPressIsReadyButton:(UIGestureRecognizer *)sender {
    
    QZBUserWithTopic *userWithTopic = [self.room findUser:[QZBCurrentUser sharedInstance].user];
    
    [self makeCurrentUserReady:!userWithTopic.isReady];
 //   NSLog(@"gtfo");
}


#pragma mark - Navigation


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:QZBShowFriendsChooserSegieIdentifier]){
        QZBFriendsChooserRoomsController *destinationVC = segue.destinationViewController;
        QZBUser *user = [QZBCurrentUser sharedInstance].user;
        NSNumber *roomID = self.room.roomID;
        [[QZBServerManager sharedManager]
         GETAllFriendsOfUserWithID:user.userID
             OnSuccess:^(NSArray *friends) {
                 QZBUser *user = [QZBCurrentUser sharedInstance].user;
                 [destinationVC setFriendsOwner:user andFriends:friends inRoomWithID:roomID];

                 
                                                          }
                                                          onFailure:^(NSError *error, NSInteger statusCode){
                                                              
                                                          }];

    }
}

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
        
        if([userWithTopic.user.userID isEqualToNumber:[QZBCurrentUser sharedInstance].user.userID]) {
            if(![cell.isReadyBackView.gestureRecognizers
                 containsObject:self.isReadyGestureRecognizer]){
                [cell.isReadyBackView addGestureRecognizer:self.isReadyGestureRecognizer];
            }
        }
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
        [self leaveThisRoom];
    }
}

-(void)leaveThisRoom {
    self.needRemoveObserver = YES;
    [self.navigationController popViewControllerAnimated:YES];
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


- (void)reloadRoom {
    [self.refreshControl beginRefreshing];
    [[QZBServerManager sharedManager] GETRoomWithID:self.room.roomID
                                          OnSuccess:^(QZBRoom *room) {
                                              
        [self.refreshControl endRefreshing];
        self.room = room;
        if (self.roomWorker) {
            self.roomWorker.room = self.room;
        } else {
            QZBUser *u = [QZBCurrentUser sharedInstance].user;
            if([self.room isContainUser:u]){
                [self generateRoomWorkerWithRoom:room];
            }
        }
        
        NSLog(@"room %@ roomworker %@",self.room, self.roomWorker.room);
        [self.tableView reloadData];
        
        [SVProgressHUD dismiss];
    } onFailure:^(NSError *error, NSInteger statusCode) {
        [self.refreshControl endRefreshing];
        
        if(statusCode == 404){
            [SVProgressHUD showErrorWithStatus:QZBNoRoomErrMessage];
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                         (int64_t)(2.0 * NSEC_PER_SEC)),
                           dispatch_get_main_queue(), ^{
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
    
   // [self addBarButtonRight];
    [self animateUp];
    
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
    self.needRemoveObserver = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    
    if(!self.room.owner) {
        return NO;
    }

    NSNumber *currentUserID = [QZBCurrentUser sharedInstance].user.userID;
    NSNumber *ownerUserID = self.room.owner.user.userID;

    return [currentUserID isEqualToNumber:ownerUserID];
    
   // // // return YES;
}

- (QZBRoomState)roomState {
    //    if([self isOwner] && !self.room){
    //        return @"Выбрать тему и создать комнату";
    //    }else if ()

    
    QZBUserWithTopic *userWithTopic = [self.room findUser:[QZBCurrentUser sharedInstance].user];
    if ([self isOwner]) {
        if (userWithTopic && !userWithTopic.isReady){
            return QZBRoomStateIsNotReady;
        }else if (self.room.participants.count < QZBMinimumPlayersCountInRoom) {
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
        }else if (self.room.participants.count < QZBMinimumPlayersCountInRoom) {
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
            return @"ПОДТВЕРТИТЕ ГОТОВНОСТЬ";
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
        
    [[QZBServerManager sharedManager] PATCHParticipationWithID:userWithTopic.userWithTopicID
                                                       isReady:isReady
                                                     onSuccess:^{
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

#pragma mark - show friends

-(void)showFriends {
    [self performSegueWithIdentifier:QZBShowFriendsChooserSegieIdentifier
                              sender:nil];
}

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

- (void)addBarButtonRight {
    self.navigationItem.rightBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:@"Друзья"
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self
                                                                              action:@selector(showFriends)];
}


-(UIView *)bottomView{
    if(!_bottomView){
        
        CGRect r = [UIScreen mainScreen].bounds;
        
        
        CGRect destRect = CGRectMake(0, r.size.height, r.size.width, 80);
        
        UIView *v = [[UIView alloc] initWithFrame:destRect];
     //   UIColor *firstColor = [UIColor colorWithRed:31.0/255.0 green:181.0/255.0 blue:215.0/255.0 alpha:1];
//        UIColor *secondColor = [UIColor colorWithRed:254.0/255.0
//                                               green:204/255.0
//                                                blue:81.0/255.0
//                                               alpha:1.0];
        UIColor *thirdColor = [UIColor colorWithRed:22.0/255.0
                                              green:131.0/255.0
                                               blue:199.0/255.0
                                              alpha:1];
        v.backgroundColor = thirdColor;//[UIColor colorWithRed:31.0/255.0 green:181.0/255.0 blue:215.0/255.0 alpha:1];
        _bottomView = v;
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, r.size.width-10, 80)];
//        label.font = [UIFont systemFontOfSize:20];
//        label.textColor = [UIColor whiteColor];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        button.frame = CGRectMake(10, 10, r.size.width - 20, 60);
        [button setTitle:@"Пригласить друзей!" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldMuseoFontOfSize:22];//boldSystemFontOfSize:20];
        
        [button setBackgroundColor:thirdColor];
        button.layer.cornerRadius = 2.0;
        button.layer.shadowOffset = CGSizeMake(0, 2);
        button.layer.shadowColor = [UIColor blackColor].CGColor;
        button.layer.shadowOpacity = 0.01;
        
        [button addTarget:self action:@selector(showFriends)
         forControlEvents:UIControlEventTouchUpInside];
        
        
        [v addSubview:button];
//        label.numberOfLines = 2;
//        label.text = @"Заказ на сумму 0 р.\n(минимум 1500 р.)";
//        self.orderLabel = label;
//        self.makeOrderButton = button;
//        [v addSubview:label];
        
        
        
    }
    
    return _bottomView;
    
}


-(void)animateUp {
    CGRect r = [UIScreen mainScreen].bounds;
    [self.navigationController.view addSubview:self.bottomView];
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.bottomView.frame = CGRectMake(0, r.size.height - 80, r.size.width, 80);
    }];
}

-(void)animateDown {
    CGRect r = [UIScreen mainScreen].bounds;
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.bottomView.frame = CGRectMake(0, r.size.height , r.size.width, 80);
                     } completion:^(BOOL finished) {
                         [self.bottomView removeFromSuperview];
                     }];
}

//-(void)addBottomView {
//    CGRect r = [UIScreen mainScreen].bounds;
//    
//    CGRect destFrame = CGRectMake(0, r.size.height-50, <#CGFloat width#>, <#CGFloat height#>)
//    UIView *v = [UIView alloc] initWithFrame:<#(CGRect)#>
//    
//}

@end
