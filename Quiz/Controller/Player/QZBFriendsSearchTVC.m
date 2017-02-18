#import "QZBFriendsSearchTVC.h"
#import "QZBFriendsTVC+QZBFriendsCategory.h"

@interface QZBFriendsSearchTVC () <UIScrollViewDelegate>

@end

@implementation QZBFriendsSearchTVC

- (void)viewDidLoad {
  [super viewDidLoad];

}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self.searchBar becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  //[SVProgressHUD dismiss];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  [self.searchBar resignFirstResponder];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {

  [self searchWithSearchBar:searchBar];

}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
  if (searchText.length != 0) {
    [self searchWithSearchBar:searchBar];
  } else {
    [self setFriendsOwner:nil andFriends:nil];
  }

}


@end
