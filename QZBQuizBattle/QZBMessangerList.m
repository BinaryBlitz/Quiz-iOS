//
//  QZBMessangerList.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 09/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBMessangerList.h"
#import "QZBMessagerVC.h"


#import "QZBLayerMessagerManager.h"

#import "QZBFirstMessageCell.h"
#import "QZBAnotherUserWithLastMessages.h"
#import "UIViewController+QZBControllerCategory.h"

#import <LayerKit/LayerKit.h>

@interface QZBMessangerList()

@property(strong, nonatomic) id<QZBUserProtocol> user;
@property(strong, nonatomic) NSArray *listOfUsers;

@end

@implementation QZBMessangerList

#pragma mark - Navigation

-(void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Сообщения";
    [self initStatusbarWithColor:[UIColor blackColor]];
    if(![QZBLayerMessagerManager sharedInstance].layerClient.authenticatedUserID) {
        [[QZBLayerMessagerManager sharedInstance] connectWithCompletion:^(BOOL success, NSError *error) {
            
        }];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
     self.tabBarController.tabBar.hidden = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadMessages)
                                                 name:LYRClientObjectsDidChangeNotification
                                               object:nil];
    
  //  [QZBMessagerManager sharedInstance].delegate = self;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"QZBDoNotNeedShowMessagerNotifications"
                                                        object:nil];
    
    [self reloadMessages];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"QZBFriendRequestUpdated"
                                                        object:nil];
    
   // [self setFriendsOwner:nil andFriends:[[QZBMessagerManager sharedInstance] usersInStorage]];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"QZBNeedShowMessagerNotifications"
                                                        object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([segue.identifier isEqualToString:@"showMessager"]){
        QZBMessagerVC *destVC = (QZBMessagerVC *)segue.destinationViewController;
        [destVC initWithUser:self.user];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.listOfUsers.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    QZBFirstMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell"];
    
    QZBAnotherUserWithLastMessages *userWithLastMessage = self.listOfUsers[indexPath.row];
    
    [cell setCellWithUserWithLastMessage:userWithLastMessage];
    
    return cell;
    
    
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    QZBAnotherUserWithLastMessages *userAndMess = self.listOfUsers[indexPath.row];
    
   // [userAndMess readAllMessages];
    
    self.user = userAndMess.user;
    
  //  self.user = [self userAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:@"showMessager" sender:nil];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 71.0;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


#pragma mark - message delegate

-(void)didRecieveMessageFrom:(NSString *)bareJid text:(NSString *)text{
    
    [self reloadMessages];
    
}

-(void)reloadMessages{
    
//    NSArray *conversations = [[QZBLayerMessagerManager sharedInstance] conversations];
//    
//    for(LYRConversation *conv in conversations) {
//        NSLog(@" %@", conv);
//    }
    
    self.listOfUsers = [[QZBLayerMessagerManager sharedInstance] conversations];
    
    [self.tableView reloadData];
}
@end
