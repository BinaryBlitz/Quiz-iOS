//
//  QZBRoomController.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 16/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRoomController.h"
#import "QZBRoom.h"
#import "QZBGameTopic.h"
#import "QZBUserWithTopic.h"
#import "UIViewController+QZBControllerCategory.h"
#import "QZBCurrentUser.h"

#import "QZBEnterRoomCell.h"
#import "QZBUserInRoomCell.h"

#import "QZBServerManager.h"

//cells
NSString *const QZBUserInRoomCellIdentifier = @"userInRoomCellIdentifier";
NSString *const QZBEnterRoomCellIdentifier = @"enterRoomCellIdentifier";

//segues
NSString *const QZBShowRoomCategoryChooser = @"showRoomCategoryChooser";


//lastButtonStateEnum

typedef NS_ENUM(NSInteger, QZBRoomState) {
    QZBRoomStateChooseAndCreate,
    QZBRoomStateWaitingPlayers,
    QZBRoomStateCanStartGame,
    QZBRoomStateWaitStartGame,
    QZBRoomStateChooseAndJoin,
    QZBRoomStateNone
};

@interface QZBRoomController()

@property(strong, nonatomic) QZBRoom *room;
@property(strong, nonatomic) QZBGameTopic *selectedTopic;
@property(strong, nonatomic) NSMutableArray *usersWithTopics;

//@property(assign, nonatomic) BOOL shouldShowEnterRoomCell;

@end

@implementation QZBRoomController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    
    self.usersWithTopics = [NSMutableArray array];
   // [self initStatusbarWithColor:[UIColor blackColor]];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initStatusbarWithColor:[UIColor blackColor]];
    


}

- (void)initWithRoom:(QZBRoom *)room {
    
    self.room = room;
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger count = self.usersWithTopics.count;
    //if(self.shouldShowEnterRoomCell){
        count++;
    //}
    return count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row < [tableView numberOfRowsInSection:0]-1){
        QZBUserInRoomCell *cell = [tableView dequeueReusableCellWithIdentifier:QZBUserInRoomCellIdentifier];
        
        QZBUserWithTopic *userWithTopic = self.usersWithTopics[indexPath.row];
        
        [cell configureCellWithUserWithTopic:userWithTopic];
        return cell;
    }else{
        
        QZBEnterRoomCell *cell = [tableView dequeueReusableCellWithIdentifier:QZBEnterRoomCellIdentifier];
        cell.enterRoomLabel.text = [self stringForCurrentState];
        
        return cell;

    }
    
}

#pragma mark - UITableViewDelegate



- (void)showCategoryChooser{
    [self performSegueWithIdentifier:QZBShowRoomCategoryChooser sender:nil];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if([cell isKindOfClass:[QZBEnterRoomCell class]]){
        [self performSegueWithIdentifier:QZBShowRoomCategoryChooser sender:nil];
    }
    
}

#pragma mark - setting room

- (void)setCurrentUserTopic:(QZBGameTopic *)topic {
    //self.selectedTopic = topic;
    
    
    if(!self.room){
        [[QZBServerManager sharedManager] POSTCreateRoomWithTopic:topic
                                                          private:NO
                                                        OnSuccess:^(QZBRoom *room) {
                                                            
                                                            self.room = room;
                                                            [self addUserInRoomWithTopic:topic];
        } onFailure:^(NSError *error, NSInteger statusCode) {
            
        }];
        
    }else{
        [[QZBServerManager sharedManager] POSTJoinRoomWithID:self.room.roomID withTopic:topic onSuccess:^{
            [self addUserInRoomWithTopic:topic];
        } onFailure:^(NSError *error, NSInteger statusCode) {
            
        }];
    }
    
    
//    QZBUser *u = [QZBCurrentUser sharedInstance].user;
//    QZBUserWithTopic *uAndT = [[QZBUserWithTopic alloc] initWithUser:u
//                                                               topic:self.selectedTopic];
//    
//    [self.usersWithTopics addObject:uAndT];
//    [self.tableView reloadData];
}

-(void)addUserInRoomWithTopic:(QZBGameTopic *)topic{
    
    self.selectedTopic = topic;
    QZBUser *u = [QZBCurrentUser sharedInstance].user;
    QZBUserWithTopic *uAndT = [[QZBUserWithTopic alloc] initWithUser:u
                                                               topic:self.selectedTopic];
    
    [self.usersWithTopics addObject:uAndT];
    [self.tableView reloadData];

    
}

#pragma mark - support methods

-(BOOL)shouldShowEnterRoomCell{
    return YES;
}

-(BOOL)isOwner{
    return YES;
}

//-(BOOL)canStartGame{
//    return YES;
//}



-(QZBRoomState)roomState{
//    if([self isOwner] && !self.room){
//        return @"Выбрать тему и создать комнату";
//    }else if (<#expression#>)
    
    if([self isOwner]){
        if(!self.room){
            return QZBRoomStateChooseAndCreate;
        }else if(self.usersWithTopics.count<3){
            return QZBRoomStateWaitingPlayers;
        }else{
            return QZBRoomStateCanStartGame;
        }
    }else{
        if(!self.selectedTopic){
            return QZBRoomStateChooseAndJoin;
        }else if(self.usersWithTopics.count<3){
            return QZBRoomStateWaitingPlayers;
        }else{
            return QZBRoomStateWaitingPlayers;
        }
    }
    
}

-(NSString *)stringForState:(QZBRoomState)roomState{
    switch (roomState) {
        case QZBRoomStateCanStartGame:
            return @"Начать игру";
            break;
        case QZBRoomStateWaitStartGame:
            return @"Ждем начала игры";
            break;
        case QZBRoomStateChooseAndJoin:
            return @"Выбрать тему и присоединиться к комнате";
            break;
        case QZBRoomStateChooseAndCreate:
            return @"Выбрать тему и создать комнату";
            break;
        case QZBRoomStateWaitingPlayers:
            return @"Ждем игроков";
            break;
        case QZBRoomStateNone:
            return @"";
            break;
        default:
            return @"";
            break;
    }
}

-(NSString *)stringForCurrentState{
    QZBRoomState s = [self roomState];
    
    return [self stringForState:s];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


@end
