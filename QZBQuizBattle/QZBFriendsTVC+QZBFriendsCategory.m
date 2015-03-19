//
//  QZBFriendsTVC+QZBFriendsCategory.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 18/03/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBFriendsTVC+QZBFriendsCategory.h"
#import <SVProgressHUD.h>
#import "QZBServerManager.h"

@implementation QZBFriendsTVC (QZBFriendsCategory)

- (void)searchWithSearchBar:(UISearchBar *)searchBar {
    if(searchBar.text.length > 30){
        return;
    }
    
    NSLog(@"search taped");
    [SVProgressHUD show];

    [[QZBServerManager sharedManager] GETSearchFriendsWithText:searchBar.text
        OnSuccess:^(NSArray *friends) {

            if (friends.count == 0) {
                [SVProgressHUD showInfoWithStatus:@"Ничего не найдено,\n попробуйте другой "
                                                  @"запрос"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)),
                               dispatch_get_main_queue(), ^{
                                   [SVProgressHUD dismiss];
                               });
            } else {
                [self setFriendsOwner:nil andFriends:friends];
                [SVProgressHUD dismiss];
            }

        }
        onFailure:^(NSError *error, NSInteger statusCode) {
            [SVProgressHUD showInfoWithStatus:@"Проверьте интернет "
                                              @"соединение"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)),
                           dispatch_get_main_queue(), ^{
                               [SVProgressHUD dismiss];
                           });

        }];
}

@end
