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



// cells
NSString *const QZBUserInRoomCellIdentifier = @"userInRoomCellIdentifier";
NSString *const QZBEnterRoomCellIdentifier  = @"enterRoomCellIdentifier";

// segues
NSString *const QZBShowRoomCategoryChooser  = @"showRoomCategoryChooser";
NSString *const QZBShowGameController       = @"showGameController";

// lastButtonStateEnum
typedef NS_ENUM(NSInteger, QZBRoomState) {
    QZBRoomStateChooseAndCreate,
    QZBRoomStateWaitingPlayers,
    QZBRoomStateCanStartGame,
    QZBRoomStateWaitStartGame,
    QZBRoomStateChooseAndJoin,
    QZBRoomStateNone
};

@interface QZBRoomController () <UIAlertViewDelegate>

@property (strong, nonatomic) QZBRoom *room;

@property (strong, nonatomic) QZBRoomWorker *roomWorker;
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
    

    //  self.usersWithTopics = [NSMutableArray array];
    // [self initStatusbarWithColor:[UIColor blackColor]];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initStatusbarWithColor:[UIColor blackColor]];

    [self backButtonInit];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(leaveOrDeleteRoom)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(leaveOrDeleteRoom)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    [self leaveOrDeleteRoom];
    
}

- (void)initWithRoom:(QZBRoom *)room {
    self.room = room;
    
    if([self isOwner]){
        [self generateRoomWorkerWithRoom:room];
    }

    [self setTitleWithRoom:room];
}

#pragma mark - actions

- (void)leaveRoom {
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
    if (self.room) {
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

- (void)startGame {
    [[QZBServerManager sharedManager] POSTStartRoomWithID:self.room.roomID onSuccess:^{
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
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
            if(roomState != QZBRoomStateCanStartGame){
                [self performSegueWithIdentifier:QZBShowRoomCategoryChooser sender:nil];
            } else {
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
    // self.selectedTopic = topic;

//    if (!self.room) {
//        [[QZBServerManager sharedManager] POSTCreateRoomWithTopic:topic
//            private:NO
//            OnSuccess:^(QZBRoom *room) {
//
//                self.room = room;
//                [self setTitleWithRoom:room];
//                [self.tableView reloadData];
//                //[self addUserInRoomWithTopic:topic];
//            }
//            onFailure:^(NSError *error, NSInteger statusCode){
//
//            }];
//
//    } else {
    
    
        [[QZBServerManager sharedManager] POSTJoinRoomWithID:self.room.roomID
            withTopic:topic
            onSuccess:^{
                [self addUserInRoomWithTopic:topic];
                [self generateRoomWorkerWithRoom:self.room];
            }
            onFailure:^(NSError *error, NSInteger statusCode){

            }];
//    }
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
        [self.tableView reloadData];
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
    }];
}

-(void)generateRoomWorkerWithRoom:(QZBRoom *)room {
    self.roomWorker = [[QZBRoomWorker alloc] initWithRoom:room];

    [self.roomWorker addRoomOnlineWorker];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showGameController)
                                                 name:QZBNeedStartRoomGame object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadRoom) name:QZBNewParticipantJoinedRoom object:nil];
    
    
    
}

-(void)showGameController{
    
    QZBGameTopic *topic = self.room.owner.topic;
    
    [[QZBSessionManager sessionManager] setTopicForSession:topic];
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

    if ([self isOwner]) {
        if (!self.room) {
            return QZBRoomStateChooseAndCreate;
        } else if (self.room.participants.count < 2) {
            return QZBRoomStateWaitingPlayers;
        } else {
            return QZBRoomStateCanStartGame;
        }
    } else {
        QZBUser *user = [QZBCurrentUser sharedInstance].user;
        if (![self.room isContainUser:user]) {
            return QZBRoomStateChooseAndJoin;
        } else if (self.room.participants.count < 2) {
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
        case QZBRoomStateChooseAndCreate:
            return @"";
            break;
        case QZBRoomStateWaitingPlayers:
            return @"ЖДЕМ ИГРОКОВ";
            break;
        case QZBRoomStateNone:
            return @"";
            break;
        default:
            return @"";
            break;
    }
}

- (BOOL)canPressLastButton {
    QZBRoomState roomState = [self roomState];
    if (roomState == QZBRoomStateChooseAndCreate || roomState == QZBRoomStateChooseAndJoin ||
        roomState == QZBRoomStateCanStartGame) {
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

#pragma mark - ui

- (void)backButtonInit {
    //   UIBarButtonItem *bbItem = [UIBarButtonItem alloc] initWithCustomView:
    UIBarButtonItem *logoutButton =
        [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cancelCross"]
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(leaveRoom)];

    self.navigationItem.leftBarButtonItem = logoutButton;
}

@end
