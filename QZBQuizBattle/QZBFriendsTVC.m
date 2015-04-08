//
//  QZBFriendsTVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 24/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBFriendsTVC.h"
#import "QZBFriendCell.h"
#import "QZBServerManager.h"
#import "QZBAnotherUser.h"
#import "QZBPlayerPersonalPageVC.h"
#import "QZBFriendsRequestsTVC.h"
#import "QZBRequestUser.h"
#import <JSBadgeView/JSBadgeView.h>
#import "UIBarButtonItem+Badge.h"

@interface QZBFriendsTVC ()

@property (strong, nonatomic) NSArray *friends;          // QZBAnotherUser
@property (strong, nonatomic) NSArray *friendsRequests;  // QZBAnotherUser
@property (strong, nonatomic) id<QZBUserProtocol> user;


@end

@implementation QZBFriendsTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Друзья";
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //    [[QZBServerManager sharedManager] GETAllFriendsOfUserWithID:self.user.userID
    //                                                      OnSuccess:^(NSArray *friends) {
    //                                                          self.friends = friends;
    //                                                          [self.tableView reloadData];
    //                                                      }
    //                                                      onFailure:^(NSError *error, NSInteger
    //                                                      statusCode){
    //
    //                                                      }];
}

#pragma mark - custom init

- (void)setFriendsOwner:(id<QZBUserProtocol>)user
                friends:(NSArray *)friends
        friendsRequests:(NSArray *)friendsRequest {
    if (friendsRequest && friendsRequest.count > 0) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0,0,100, 20);
        [button addTarget:self action:@selector(showFriendsRequestsAction:) forControlEvents:UIControlEventTouchUpInside];
        

        NSString *requestTitle = @"Заявки";

        [button setTitle:requestTitle forState:UIControlStateNormal];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        
        self.friendsRequests = friendsRequest;
        self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithCustomView:button];
        
        NSInteger count = 0;
        if(friendsRequest ){
            count = [self badgeNumberWithRequestFriends:friendsRequest];
        }
        if(count>0){
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            //[NSString stringWithFormat:@"Заявки (%ld)", count];
            self.navigationItem.rightBarButtonItem.badgeValue =
            [NSString stringWithFormat:@"%ld",(long)count];
            
        }
        
       

    } else {
        // self.friendsRequestsButton.enabled = NO;
    }

    [self setFriendsOwner:user andFriends:friends];
}

- (NSInteger)badgeNumberWithRequestFriends:(NSArray *)arr {
    NSInteger count = 0;
    
    for (QZBRequestUser *user in arr) {
        if (!user.viewed) {
            count++;
        }
    }
    return count;
}


- (void)setFriendsOwner:(id<QZBUserProtocol>)user friendsRequests:(NSArray *)friendsRequest {
}

- (void)setFriendsOwner:(id<QZBUserProtocol>)user andFriends:(NSArray *)friends {
    self.user = user;
    self.friends = friends;

    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.

    return self.friends.count;
}
//
//    if(self.friendsRequests && self.friendsRequests.count>0){
//        return self.friendsRequests.count +self.friends.count+1;
//    }else{
//
//    return self.friends.count;
//    }

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QZBFriendCell *cell =
        [self.tableView dequeueReusableCellWithIdentifier:@"friendCell" forIndexPath:indexPath];

    QZBAnotherUser *user = self.friends[indexPath.row];

    [cell setCellWithUser:user];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath
*)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath]
withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the
array, and add a new
row to the table view
    }
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath
*)fromIndexPath
toIndexPath:(NSIndexPath
*)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath
*)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/



#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    if (![cell isKindOfClass:[QZBFriendCell class]]) {
        return;
    }

    QZBFriendCell *friendCell = (QZBFriendCell *)cell;
    self.user = friendCell.user;

    [self performSegueWithIdentifier:@"showUserpage" sender:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
// preparation before
// navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showUserpage"]) {
        QZBPlayerPersonalPageVC *vc = segue.destinationViewController;

        [vc initPlayerPageWithUser:self.user];

    } else if ([segue.identifier isEqualToString:@"showFriendsRequests"]) {
        QZBFriendsRequestsTVC *destinationVC =
            (QZBFriendsRequestsTVC *)segue.destinationViewController;

        [destinationVC setFriendsOwner:self.user andFriends:self.friendsRequests];
    }
}

#pragma mark - actions
- (void)showFriendsRequestsAction:(id)sender {
    [self performSegueWithIdentifier:@"showFriendsRequests" sender:nil];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark - support methods

-(id<QZBUserProtocol>)userAtIndex:(NSUInteger)userIndex{
    
    if(userIndex<self.friends.count){
        return [self.friends objectAtIndex:userIndex];
    }else{
        return nil;
    }
    
}

@end
