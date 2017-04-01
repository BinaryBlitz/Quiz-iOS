#import "QZBFriendsChooserRoomsController.h"
#import "QZBServerManager.h"
#import <SVProgressHUD.h>

NSString *const QZBUserAlreadyInvited = @"Пользователе уже приглашен";

@interface QZBFriendsChooserRoomsController ()

@property (strong, nonatomic) NSNumber *roomID;

@end

@implementation QZBFriendsChooserRoomsController

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"QZBDoNotNeedShowMessagerNotifications"
                                                      object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];

  [[NSNotificationCenter defaultCenter] postNotificationName:@"QZBNeedShowMessagerNotifications"
                                                      object:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];

  id <QZBUserProtocol> user = [self userAtIndex:indexPath.row];
  [self inviteUser:user];
}

- (void)inviteUser:(id <QZBUserProtocol>)user {
  [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
  [[QZBServerManager sharedManager] POSTInviteFriendWithID:user.userID inRoomWithID:self.roomID onSuccess:^{
    [SVProgressHUD showSuccessWithStatus:@"Друг приглашен"];
  }                                              onFailure:^(NSError *error, NSInteger statusCode) {
    if (statusCode == 422) {
      [SVProgressHUD showErrorWithStatus:QZBUserAlreadyInvited];
    } else {

      [SVProgressHUD showErrorWithStatus:QZBNoInternetConnectionMessage];
    }
  }];
}

- (void)setFriendsOwner:(id <QZBUserProtocol>)user
             andFriends:(NSArray *)friends
           inRoomWithID:(NSNumber *)roomID {
  [self setFriendsOwner:user andFriends:friends];
  self.roomID = roomID;
}

@end
