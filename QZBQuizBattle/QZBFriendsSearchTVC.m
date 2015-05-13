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
    //[SVProgressHUD dismiss];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.searchBar resignFirstResponder];
}


#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    [self searchWithSearchBar:searchBar];
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    [self searchWithSearchBar:searchBar];
    
    
}



@end
