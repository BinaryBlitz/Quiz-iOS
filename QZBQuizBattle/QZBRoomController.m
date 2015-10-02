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
#import "QZBRoomCommentController.h"

//ui

#import <SVProgressHUD.h>
#import "UIFont+QZBCustomFont.h"
#import "QZBRoomFakeKeyboard.h"

// cells
NSString *const QZBUserInRoomCellIdentifier = @"userInRoomCellIdentifier";
NSString *const QZBEnterRoomCellIdentifier  = @"enterRoomCellIdentifier";

// segues
NSString *const QZBShowRoomCategoryChooser  = @"showRoomCategoryChooser";
NSString *const QZBShowGameController       = @"showGameController";
NSString *const QZBShowFriendsChooserSegieIdentifier = @"showFriendsChooser";
static NSString *const QZBShowChatFromRoomController = @"showChatFromRoomController";

//message

NSString *const QZBNoRoomErrMessage = @"Комната была удалена";
NSString *const QZBNoPlacesInRoom = @"Все места в комнате заняты";
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

const NSInteger QZBMinimumPlayersCountInRoom = 3;//REDO
const NSInteger QZBMaxLeaveTime = 20;

@interface QZBRoomController () <UIAlertViewDelegate>
@property (strong, nonatomic) QZBRoom *room;
@property (strong, nonatomic) QZBRoomWorker *roomWorker;
@property (assign, nonatomic) BOOL isLeaveRoom;
@property (assign, nonatomic) BOOL isStarted;
@property(assign, nonatomic) BOOL needRemoveObserver;
@property (strong, nonatomic) UITapGestureRecognizer *isReadyGestureRecognizer;
@property(strong, nonatomic) UIView *bottomView;
@property (strong, nonatomic) NSAttributedString *stringWithCross;
@property (strong, nonatomic) NSAttributedString *stringWithCrown;
@property (assign, nonatomic) UIEdgeInsets edgeInset;
@property (strong, nonatomic) UIView *fakeKeyboard;

//new rooms
@property (assign, nonatomic) NSInteger time;
@property (strong, nonatomic) NSTimer *globalTimer;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (assign, nonatomic) NSInteger maxTime;
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
    self.tableView.contentInset = self.edgeInset;
    [self reloadRoom];
    
    UIImage *crossImage = [[UIImage imageNamed:@"cancelCross"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = crossImage;
    self.stringWithCross = [NSAttributedString attributedStringWithAttachment:attachment];
    
    //[self.navigationController setToolbarHidden:NO animated:YES];
    self.isReadyGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                         action:@selector(userPressIsReadyButton:)];
    
    self.isReadyGestureRecognizer.numberOfTapsRequired = 1;
    self.isReadyGestureRecognizer.numberOfTouchesRequired = 1;


}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    [self initStatusbarWithColor:[UIColor blackColor]];

    [self backButtonInit];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"QZBDoNotNeedShowMessagerNotifications"
                                                        object:nil];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(leaveRoomWithWithDelay)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(leaveThisRoom)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userBackFromBackgound)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    //TODO закрытвать экран
    
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(self.roomWorker){
        [self animateUp];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self animateDown];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"QZBNeedShowMessagerNotifications"
                                                        object:nil];
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

//-(void)viewDidLayoutSubviews {
//    [super viewDidLayoutSubviews];
//    self.tableView.contentInset = self.edgeInset;
//}



#pragma mark - actions

- (void)leaveCurrentRoom {
    QZBUser *user = [QZBCurrentUser sharedInstance].user;

    if (!self.room || ![self.room isContainUser:user]) {
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

-(void)leaveRoomWithMessage:(NSString *)message {
    [SVProgressHUD showErrorWithStatus:message];
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
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
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

    } else if ([segue.identifier isEqualToString:QZBShowChatFromRoomController]) {
        QZBRoomCommentController *destVC = (QZBRoomCommentController *)segue.destinationViewController;
        [destVC configureWithRoomID:self.room.roomID];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger count = self.room.participants.count + 1;

    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [tableView numberOfRowsInSection:0] - 1) {
        QZBUserInRoomCell *cell =
            [tableView dequeueReusableCellWithIdentifier:QZBUserInRoomCellIdentifier];
        
        QZBUserWithTopic *userWithTopic = self.room.participants[indexPath.row]; //redo
        
        if([userWithTopic.user.userID isEqualToNumber:[QZBCurrentUser sharedInstance].user.userID]) {
            if(![cell.isReadyBackView.gestureRecognizers
                 containsObject:self.isReadyGestureRecognizer]){
                [cell.isReadyBackView addGestureRecognizer:self.isReadyGestureRecognizer];
            }
        }
        [cell configureCellWithUserWithTopic:userWithTopic];
        if(userWithTopic.admin){
            NSString *tmp = [NSString stringWithFormat:@"%@ ",cell.usernameLabel.text];
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc]
                                              initWithString:tmp];
            [str appendAttributedString:self.stringWithCrown];
            cell.usernameLabel.attributedText = str;
        }
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
    NSArray *arr = self.navigationController.viewControllers;
    UIViewController *destVC = nil;
    for(int i = 0;i<arr.count;i++){
        UIViewController *c = arr[i];
        if([c isKindOfClass:[self class]]){
            destVC = arr[i-1];
            break;
        }
    }
    if(destVC){
        [self.navigationController popToViewController:destVC animated:YES];
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
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

                [self generateRoomWorkerWithRoom:self.room];
                [self reloadRoom];
                [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeNone];
            }
            onFailure:^(NSError *error, NSInteger statusCode){
                if(statusCode == 403) {
                    [self leaveRoomWithMessage:QZBNoPlacesInRoom];
                }
                
            }];
}

- (void)addUserInRoomWithTopic:(QZBGameTopic *)topic {
   // self.selectedTopic = topic;
    QZBUser *u = [QZBCurrentUser sharedInstance].user;
    QZBUserWithTopic *uAndT = [[QZBUserWithTopic alloc] initWithUser:u topic:topic];

    [self.room addUser:uAndT];
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

            [self leaveRoomWithMessage:QZBNoRoomErrMessage];
        }
    }];
}

-(void)generateRoomWorkerWithRoom:(QZBRoom *)room {
    self.roomWorker = [[QZBRoomWorker alloc] initWithRoom:room];

    [self.roomWorker addRoomOnlineWorker];
    [self addBarButtonRight];
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

-(void)showChat {
    [self performSegueWithIdentifier:QZBShowChatFromRoomController sender:nil];
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
    QZBUserWithTopic *userWithTopic = [self.room findUser:[QZBCurrentUser sharedInstance].user];
    if ([self isOwner]) {
        if (userWithTopic && !userWithTopic.isReady){
            return QZBRoomStateIsNotReady;
        }else if (self.room.participants.count < QZBMinimumPlayersCountInRoom || [self checkAllReady]) {
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

-(BOOL)checkAllReady {
    for(QZBUserWithTopic *userWithTopic in self.room.participants) {
        if(!userWithTopic.ready) {
            return NO;
        }
    }
    return YES;
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
            return @"ПОДТВЕРДИТЕ ГОТОВНОСТЬ";
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
        
        QZBUserInRoomCell *userInRoomCell = (QZBUserInRoomCell *)[self.tableView
                                                                  cellForRowAtIndexPath:ip];
        
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




-(UIView *)bottomView{
    if(!_bottomView){
        
        CGRect r = [UIScreen mainScreen].bounds;
        
        //CGSize navRect = self.navigationController.view.frame.size;
        CGRect destRect = CGRectMake(0, r.size.height, r.size.width, 80);
        
        UIView *v = [[UIView alloc] initWithFrame:destRect];

        UIColor *thirdColor = [UIColor colorWithRed:22.0/255.0
                                              green:131.0/255.0
                                               blue:199.0/255.0
                                              alpha:1];
        v.backgroundColor = thirdColor;
        _bottomView = v;

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
    }
    
    return _bottomView;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(_bottomView){
    CGRect frame = self.bottomView.frame;
    frame.origin.y = scrollView.contentOffset.y + self.tableView.frame.size.height -
        self.bottomView.frame.size.height;
    self.bottomView.frame = frame;
    
    //[self.view bringSubviewToFront:self.bottomView];
    }
    
    if(_fakeKeyboard) {
        CGRect frame = self.fakeKeyboard.frame;
        frame.origin.y = scrollView.contentOffset.y + self.tableView.frame.size.height -
        self.fakeKeyboard.frame.size.height;
        self.fakeKeyboard.frame = frame;
        
        [self.view bringSubviewToFront:self.fakeKeyboard];
    }
    
}


-(void)animateUp {
    CGRect r = self.view.frame;//[UIScreen mainScreen].bounds;
    [self.view addSubview:self.bottomView];
    [self.view bringSubviewToFront:self.bottomView];
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.bottomView.frame = CGRectMake(0,
                                                            self.tableView.contentOffset.y +
                                                            self.tableView.frame.size.height -
                                                            self.bottomView.frame.size.height,
                                                            r.size.width,
                                                            80);
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


-(void)addBarButtonRight {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0,0,20, 20);
    [button addTarget:self action:@selector(keyboardShowAction) forControlEvents:UIControlEventTouchUpInside];

    UIImage *messageIcon = [UIImage imageNamed:@"messageIcon"];
    [button setBackgroundImage:messageIcon forState:UIControlStateNormal];
    
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithCustomView:button];
}


#pragma mark - lazy

-(NSAttributedString *)stringWithCrown {
    if(!_stringWithCrown) {
        UIImage *crossImage = [UIImage imageNamed:@"crownIcon"];
                               
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = crossImage;
        
        NSMutableAttributedString *begStr = [[NSAttributedString
                                             attributedStringWithAttachment:attachment] mutableCopy];
        
        [begStr addAttribute:NSForegroundColorAttributeName value:[UIColor goldColor] range:NSMakeRange(0,1)];
        _stringWithCrown = [[NSAttributedString alloc] initWithAttributedString:begStr];
    }
    return _stringWithCrown;
}

-(UIView *)fakeKeyboard {
    if(!_fakeKeyboard) {
        QZBRoomFakeKeyboard *v = (QZBRoomFakeKeyboard *)[[[NSBundle mainBundle] loadNibNamed:@"QZBRoomFakeKeyboard"
                                                   owner:self
                                                 options:nil] objectAtIndex:0];
        
        CGSize size = [UIScreen mainScreen].bounds.size;
        
        v.frame = CGRectMake(0, size.height, size.width, size.height/3.9);
        v.backgroundColor = [UIColor darkGrayColor];
        
        for(UIButton *button in v.phrasesButtons) {
            button.tintColor = [UIColor whiteColor];
            [button addTarget:self
                       action:@selector(fakeKeyboardAction:)
             forControlEvents:UIControlEventTouchUpInside];
            [button setExclusiveTouch:YES];
        }
        [v.closeButton addTarget:self
                          action:@selector(keyboardShowAction)
                forControlEvents:UIControlEventTouchUpInside];
        v.closeButton.imageView.tintColor = [UIColor whiteColor];
        UIImage *cancelCross =  [[UIImage imageNamed:@"cancelCross"]
                                 imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [v.closeButton setImage:cancelCross forState:UIControlStateNormal];
        [v.closeButton setExclusiveTouch:YES];
        _fakeKeyboard = v;
    }
    return _fakeKeyboard;
}

-(UIEdgeInsets)edgeInset {
    UIEdgeInsets general = self.tableView.contentInset;
    
    return  UIEdgeInsetsMake(general.top, 0, 80, 0);
}


#pragma mark - fake keyboard actions
-(void)keyboardShowAction {
    if([self.view.subviews containsObject:_fakeKeyboard]){
        [self animateKeyboardDown];
    } else {
        [self animateKeyboardUp];
    }
}

- (void)animateKeyboardUp {
    UIEdgeInsets general = self.tableView.contentInset;
    self.tableView.contentInset = UIEdgeInsetsMake(general.top,
                                                   0,
                                                   self.fakeKeyboard.frame.size.height,
                                                   0);
    [self.view addSubview:self.fakeKeyboard];
    [self.view bringSubviewToFront:self.fakeKeyboard];
    [UIView animateWithDuration:0.3
                     animations:^{
                         
                         CGRect frame = self.fakeKeyboard.frame;
                         frame.origin.y = self.tableView.contentOffset.y +
                         self.tableView.frame.size.height -
                         self.fakeKeyboard.frame.size.height;
                         self.fakeKeyboard.frame = frame;
                         
                         [self.view bringSubviewToFront:self.fakeKeyboard];

                     }];

}
-(void)animateKeyboardDown {
    self.tableView.contentInset = self.edgeInset;
    [UIView animateWithDuration:0.3
                     animations:^{
                         CGRect frame = self.fakeKeyboard.frame;
                         frame.origin.y = self.tableView.contentOffset.y +
                         self.tableView.frame.size.height;
                         self.fakeKeyboard.frame = frame;
                     } completion:^(BOOL finished) {
                         [self.fakeKeyboard removeFromSuperview];
                         self.tableView.contentInset = self.edgeInset;
                     }];
}


#pragma mark - messages

-(void)userWithID:(NSNumber *)userID say:(NSString *)message {
    NSInteger index = -1;
    
    for (int i = 0; i<self.room.participants.count;i++){
        QZBUserWithTopic *userWithTopic = self.room.participants[i];
        if([userWithTopic.user.userID isEqualToNumber:userID]) {
            index = i;
            break;
        }
    }
    if(index == -1){
        return;
    }
    
    NSIndexPath *ip = [NSIndexPath indexPathForRow:index inSection:0];
    QZBUserInRoomCell *cell = (QZBUserInRoomCell *)[self.tableView cellForRowAtIndexPath:ip];
    if(!cell){
        return;
    }
    
    CGRect r = cell.contentView.frame;
    r.origin.x = r.size.width;
    r.size.width = r.size.width - cell.isReadyBackView.frame.origin.x; //r.size.width/2.0;
    
    UIView *v = [[UIView alloc] initWithFrame:r];
    v.backgroundColor = [UIColor veryDarkGreyColor];
    v.alpha = 0;
    CGFloat offset = 20.0;
    CGRect lableR = CGRectMake(0, 0, CGRectGetWidth(r) - offset, CGRectGetHeight(r));
    
    UILabel *label = [[UILabel alloc] initWithFrame:lableR];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont museoFontOfSize:18];
    label.textAlignment = NSTextAlignmentRight;
    label.numberOfLines = 1;
    label.text = message;
    
    [v addSubview:label];
    
    [cell.contentView addSubview:v];
    
    [UIView animateWithDuration:0.4 animations:^{
        v.alpha = 1.0;
        CGRect newR = CGRectMake(cell.contentView.frame.size.width - r.size.width,
                                 0,
                                 r.size.width,
                                 r.size.height);
        v.frame = newR;
    } completion:^(BOOL finished) {
        if(finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.4
                             animations:^{
                                 v.alpha = 0.4;
                                 v.frame = r;
            } completion:^(BOOL finished) {
                
                [v removeFromSuperview];
            }];
        });
        }
    }];
}


-(void)messageTestWithMessage:(NSString *)message {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self userWithID:[QZBCurrentUser sharedInstance].user.userID say:message];
    });
}

-(void)fakeKeyboardAction:(UIButton *)sender {
    
    [self messageTestWithMessage:sender.titleLabel.text];
}

#pragma mark - new room changes

-(void)leaveRoomWithWithDelay{
    self.backgroundTask =
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }];
    [self timeCountingStart];
    [self makeCurrentUserReady:NO];
}

- (void)timeCountingStart {
    self.time = 0;
    self.globalTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                        target:self
                                                      selector:@selector(updateTime:)
                                                      userInfo:nil
                                                       repeats:YES];
    
}

- (void)updateTime:(NSTimer *)timer {
    self.time++;
    
    if(timer != self.globalTimer) {
        [timer invalidate];
        timer = nil;
        return;
    }
    if(self.time == QZBMaxLeaveTime - 5) {
        [self postLocalNotificationWithText:@"Вернитесь в игру!"];//redo text
    }
    
    if (self.time < QZBMaxLeaveTime) {
        NSLog(@"time %ld", (long)self.time);
    } else {
        if (timer != nil) {
            [self leaveThisRoom];
            self.time = 0;
            [timer invalidate];
            timer = nil;
            
            [self endBackgroundTask];
        }
    }
}

-(void)userBackFromBackgound {
    [self invalidateTimer];
    [self accentReadyButtons];
}

- (void)invalidateTimer {
    [self.globalTimer invalidate];
    self.globalTimer = nil;
    self.time = 0;
    
    [self endBackgroundTask];
}

-(void)endBackgroundTask {
    if (self.backgroundTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }
}

- (void)accentReadyButtons {
    NSLog(@"accented");
}

-(void)postLocalNotificationWithText:(NSString *)message {
    
    if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground){
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = message;//@"Комната заполнена, возвращайтесь в игру";
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
    
}


@end
