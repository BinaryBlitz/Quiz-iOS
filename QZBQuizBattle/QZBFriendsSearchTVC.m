//
//  QZBFriendsSearchTVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 11/03/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBFriendsSearchTVC.h"
#import "QZBServerManager.h"
#import "QZBFriendsTVC+QZBFriendsCategory.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface QZBFriendsSearchTVC ()<UIScrollViewDelegate>

@end

@implementation QZBFriendsSearchTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.searchBar becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.searchBar resignFirstResponder];
}


#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    [self searchWithSearchBar:searchBar];
    
//    NSLog(@"search taped");
//    [SVProgressHUD show];
//    
//    
//    [[QZBServerManager sharedManager] GETSearchFriendsWithText:searchBar.text
//OnSuccess:^(NSArray *friends) {
//    
//    
//    if(friends.count == 0){
//        [SVProgressHUD showInfoWithStatus:@"Ничего не найдено,\n попробуйте другой запрос"];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [SVProgressHUD dismiss];
//        });
//    }else{
//    
//        [self setFriendsOwner:nil andFriends:friends];
//        [SVProgressHUD dismiss];
//    }
//            
//    } onFailure:^(NSError *error, NSInteger statusCode) {
//       [SVProgressHUD showInfoWithStatus:@"Проверьте интернет соединение"];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [SVProgressHUD dismiss];
//        });
//        
//        
//    }];
    
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
