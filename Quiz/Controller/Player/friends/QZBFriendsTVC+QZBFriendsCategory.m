#import "QZBFriendsTVC+QZBFriendsCategory.h"
#import <SVProgressHUD.h>
#import "QZBServerManager.h"

@implementation QZBFriendsTVC (QZBFriendsCategory)

- (void)searchWithSearchBar:(UISearchBar *)searchBar {
  if (searchBar.text.length > 30 || searchBar.text.length < 2) {
    return;
  }

  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

  [[QZBServerManager sharedManager] GETSearchFriendsWithText:searchBar.text
                                                   OnSuccess:^(NSArray *friends) {

                                                     if (friends.count == 0) {
                                                       [self setFriendsOwner:nil andFriends:friends];
                                                       [SVProgressHUD showInfoWithStatus:@"Пользователи не найдены"];
                                                     } else {
                                                       [self setFriendsOwner:nil andFriends:friends];
                                                       [SVProgressHUD dismiss];
                                                     }
                                                     [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                   }
                                                   onFailure:^(NSError *error, NSInteger statusCode) {
                                                     [SVProgressHUD showInfoWithStatus:@"Проверьте интернет "
                                                         @"соединение"];
                                                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1.5 * NSEC_PER_SEC)),
                                                         dispatch_get_main_queue(), ^{
                                                           [SVProgressHUD dismiss];
                                                         });
                                                     [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                   }];
}

@end
