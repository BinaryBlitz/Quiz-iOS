//
//  QZBFriendsChooserRoomsController.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 16/07/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBFriendsChooserRoomsController.h"
#import "QZBFriendCell.h"
#import "QZBServerManager.h"
#import <SVProgressHUD.h>

NSString *const QZBUserAlreadyInvited = @"Пользователе уже приглашен";

@interface QZBFriendsChooserRoomsController ()

//@property (strong, nonatomic) id<QZBUserProtocol> user;

@property(strong, nonatomic) NSNumber *roomID;

@end

@implementation QZBFriendsChooserRoomsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    
//    if (![cell isKindOfClass:[QZBFriendCell class]]) {
//        return;
//    }
//    
//    QZBFriendCell *friendCell = (QZBFriendCell *)cell;
    //self.user = friendCell.user;
    
    id<QZBUserProtocol> user = [self userAtIndex:indexPath.row];
    [self inviteUser:user];
    
    //[self performSegueWithIdentifier:@"showUserpage" sender:nil];
}

//-(void)popBack {
//    [self.navigationController popViewControllerAnimated:YES];
//}

-(void)inviteUser:(id<QZBUserProtocol>) user {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[QZBServerManager sharedManager] POSTInviteFriendWithID:user.userID inRoomWithID:self.roomID onSuccess:^{
        [SVProgressHUD showSuccessWithStatus:@"Друг приглашен"];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            
//        });
//        [self.navigationController popViewControllerAnimated:YES];
    } onFailure:^(NSError *error, NSInteger statusCode) {
        if(statusCode == 422){
            [SVProgressHUD showErrorWithStatus:QZBUserAlreadyInvited];
        }else {
        
            [SVProgressHUD showErrorWithStatus:QZBNoInternetConnectionMessage];
        }
    }];
}

- (void)setFriendsOwner:(id<QZBUserProtocol>)user
            andFriends:(NSArray *)friends
          inRoomWithID:(NSNumber *)roomID {
    [self setFriendsOwner:user andFriends:friends];
    self.roomID = roomID;
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
