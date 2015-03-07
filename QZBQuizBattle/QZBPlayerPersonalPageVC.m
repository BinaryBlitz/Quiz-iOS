//
//  QZBPlayerPersonalPageVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 21/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBPlayerPersonalPageVC.h"
#import "QZBServerManager.h"
#import "QZBCurrentUser.h"
#import "QZBPlayerInfoCell.h"
#import "QZBTopicTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "QZBFriendHorizontalCell.h"
#import "QZBAchivHorizontalCell.h"
#import "QZBAchievement.h"
#import "JSBadgeView.h"
#import <TSMessages/TSMessage.h>
#import "QZBFriendsTVC.h"
#import "QZBAnotherUser.h"

//#import "DBCameraViewController.h"
//#import "DBCameraContainerViewController.h"
//#import <DBCamera/DBCameraLibraryViewController.h>
//#import <DBCamera/DBCameraSegueViewController.h>

@interface QZBPlayerPersonalPageVC () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *achivArray;
@property (strong, nonatomic) id<QZBUserProtocol> user;
@property (strong, nonatomic) NSArray *friends; //id<QZBUserProtocol>
@property (assign, nonatomic) BOOL isCurrent;
@property (assign, nonatomic) BOOL isFriend;

@end

@implementation QZBPlayerPersonalPageVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initAchivs];

    self.playerTableView.delegate = self;
    self.playerTableView.dataSource = self;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userPressShowAllButton:)
                                                 name:@"QZBUserPressShowAllButton"
                                               object:nil];
    
   

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animate {
    [super viewWillAppear:animate];

    if (!self.user ||
        [self.user.userID isEqualToNumber:[QZBCurrentUser sharedInstance].user.userID]) {
        self.user = [QZBCurrentUser sharedInstance].user;
        self.isCurrent = YES;

    } else {
        self.isCurrent = NO;
    }
    self.navigationItem.title = self.user.name;
    if(self.isCurrent){
        [self initFriendsWithUser:self.user];
    }
   // [self.tableView reloadData];
    
    

    NSLog(@"viewWillAppear %@", self.user.name);
}

- (void)dealloc {
    self.user = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initPlayerPageWithUser:(id<QZBUserProtocol>)user {
    if ([user.userID isEqualToNumber:[QZBCurrentUser sharedInstance].user.userID] || !user) {
        self.user = [QZBCurrentUser sharedInstance].user;
        self.isCurrent = YES;

    } else {
        self.user = user;
        self.isCurrent = NO;
        [[QZBServerManager sharedManager] GETPlayerWithID:user.userID onSuccess:^(QZBAnotherUser *anotherUser) {
            
            if([user isKindOfClass:[QZBAnotherUser class]]){
                QZBAnotherUser *currentUser = (QZBAnotherUser *) user;
                
                currentUser.isFriend = anotherUser.isFriend;
            }
            
            //self.user.isFriend = anotherUser.isFriend;
            NSLog(@" %d", user.isFriend);
            [self.tableView reloadData];
            
        } onFailure:^(NSError *error, NSInteger statusCode) {
            
            
            
        }];
    }
    
    [self initFriendsWithUser:self.user];

    NSLog(@"user init %@", user);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    if (self.isCurrent) {
        self.user = nil;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

// REDO player pic
//TODO refactoring

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *playerIdentifier = @"playerСell";
    static NSString *friendsIdentifier = @"friendsCell";
    static NSString *achivIdentifier = @"achivCell";

    UITableViewCell *cell;

    if (indexPath.row == 0) {
        QZBPlayerInfoCell *playerCell =
            (QZBPlayerInfoCell *)[tableView dequeueReusableCellWithIdentifier:playerIdentifier];

        [playerCell.multiUseButton addTarget:self
                                      action:@selector(multiUseButtonAction:)
                            forControlEvents:UIControlEventTouchUpInside];
        playerCell.friendsLabel.text = [NSString stringWithFormat:@"%ld", [self.friends count]];

        NSString *buttonTitle = nil;
        if (self.isCurrent) {
            buttonTitle = @"Настройки";
            [playerCell.multiUseButton setTitle:@"settings" forState:UIControlStateNormal];

            JSBadgeView *bv = [[JSBadgeView alloc] initWithParentView:playerCell.friendsButton
                                                            alignment:JSBadgeViewAlignmentTopRight];
            bv.badgeText = @"100000";
        } else {
            if(!self.user.isFriend){
                buttonTitle = @"add friend";
            }else{
                buttonTitle = @"delete from friends";
            }
        }
        [playerCell.multiUseButton setTitle:buttonTitle forState:UIControlStateNormal];

        [playerCell.playerUserpic setImage:[QZBCurrentUser sharedInstance].user.userPic];

        cell = playerCell;
    } else if (indexPath.row == 1) {
        QZBFriendHorizontalCell *friendsCell =
            [tableView dequeueReusableCellWithIdentifier:friendsIdentifier];
        return friendsCell;
        // cell = friendsCell;
    } else if (indexPath.row == 2) {
        QZBAchivHorizontalCell *achivCell =
            [tableView dequeueReusableCellWithIdentifier:achivIdentifier];

        [achivCell setAchivArray:self.achivArray];
        achivCell.buttonTitle = @"Показать\n все";
        return achivCell;
    } else if (indexPath.row == 3) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"mostLovedTopics"];

        return cell;
    } else if (indexPath.row > 3) {
        QZBTopicTableViewCell *topicCell =
            [tableView dequeueReusableCellWithIdentifier:@"topicCell"];
        topicCell.topicName.text = [NSString stringWithFormat:@"топик %ld", (long)indexPath.row];
        return topicCell;
        // cell = topicCell;
    }
    return cell;
}

- (void)userPressShowAllButton:(NSNotification *)notification {
    NSLog(@"%@", notification.object);

    NSIndexPath *indexPath = (NSIndexPath *)notification.object;

    if (indexPath.row == 1) {
        [self performSegueWithIdentifier:@"showFriendsList" sender:nil];
    } else if (indexPath.row == 2) {
        [self performSegueWithIdentifier:@"showAchivements" sender:nil];
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 3) {
        return 127.0f;
    } else if (indexPath.row == 3) {
        return 47.0f;
    } else {
        return 61.0f;
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
//preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"showFriendsList"]){
        QZBFriendsTVC *vc = (QZBFriendsTVC *)segue.destinationViewController;
        [vc setFriendsOwner:self.user andFriends:self.friends];
    }
}


#pragma mark - actions
- (IBAction)showAchivements:(UIButton *)sender {
    [self performSegueWithIdentifier:@"showAchivements" sender:nil];
}
- (IBAction)showFriendsAction:(id)sender {
    [self performSegueWithIdentifier:@"showFriendsList" sender:nil];
}

- (void)multiUseButtonAction:(id)sender {
    if (self.isCurrent) {
        [self performSegueWithIdentifier:@"showSettings" sender:nil];
    }else{
        NSNumber *friendID = self.user.userID;
        if(!self.user.isFriend){
        
        [[QZBServerManager sharedManager] POSTFriendWithID:friendID onSuccess:^{
            
            [TSMessage showNotificationInViewController:self title:@"Друг добавлен"
                                               subtitle:@""
                                                   type:TSMessageNotificationTypeSuccess
                                               duration:1];
            if([self.user isKindOfClass:[QZBAnotherUser class]]){
                
                QZBAnotherUser *currentUser = (QZBAnotherUser *)self.user;
                currentUser.isFriend = YES;
                [self.tableView reloadData];
            }
            
        } onFailure:^(NSError *error, NSInteger statusCode) {
            
        }];}else{
            
            
            [[QZBServerManager sharedManager] DELETEUNFriendWithID:friendID onSuccess:^{
                
                [TSMessage showNotificationInViewController:self title:@"Друг удален"
                                                   subtitle:@""
                                                       type:TSMessageNotificationTypeSuccess
                                                   duration:1];
                if([self.user isKindOfClass:[QZBAnotherUser class]]){
                
                    QZBAnotherUser *currentUser = (QZBAnotherUser *)self.user;
                    currentUser.isFriend = NO;
                    [self.tableView reloadData];
                }
            } onFailure:^(NSError *error, NSInteger statusCode) {
                
            }];
        }
    }
}

#pragma mark - init friends and achivs


- (void)initAchivs {
    [UIImage imageNamed:@"achiv"];
    [UIImage imageNamed:@"notAchiv"];

    self.achivArray = @[
        [[QZBAchievement alloc] initWithName:@"achiv" imageName:@"achiv"],
        [[QZBAchievement alloc] initWithName:@"notAchiv" imageName:@"notAchiv"],
        [[QZBAchievement alloc] initWithName:@"achiv2" imageName:@"achiv"],
        [[QZBAchievement alloc] initWithName:@"notAchiv2" imageName:@"notAchiv"],
        [[QZBAchievement alloc] initWithName:@"achiv" imageName:@"achiv"],
        [[QZBAchievement alloc] initWithName:@"notAchiv" imageName:@"notAchiv"],
        [[QZBAchievement alloc] initWithName:@"achiv2" imageName:@"achiv"],
        [[QZBAchievement alloc] initWithName:@"notAchiv2" imageName:@"notAchiv"]
    ];
}

#pragma mark - friends 

-(void)initFriendsWithUser:(id<QZBUserProtocol>) user{
    
    [[QZBServerManager sharedManager] GETAllFriendsOfUserWithID:user.userID OnSuccess:^(NSArray *friends) {
        self.friends = friends;
        [self.tableView reloadData];
        
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
    }];
    
    if(self.isCurrent){
        [[QZBServerManager sharedManager] GETFriendsRequestsOnSuccess:^(NSArray *friends) {
            
        } onFailure:^(NSError *error, NSInteger statusCode) {
            
        }];
    }
    
}

@end
