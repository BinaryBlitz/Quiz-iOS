#import "QZBFriendsChallengeTVC.h"
#import "QZBGameTopic.h"
#import "QZBProgressViewController.h"
#import "QZBFriendsTVC+QZBFriendsCategory.h"
#import "UIViewController+QZBControllerCategory.h"
#import "QZBCurrentUser.h"

@interface QZBFriendsChallengeTVC ()

@property (strong, nonatomic) QZBGameTopic *topic;
@property (strong, nonatomic) id <QZBUserProtocol> choosedUser;
@property (strong, nonatomic) NSArray *currentFriends;

@end

@implementation QZBFriendsChallengeTVC

- (void)viewDidLoad {
  [super viewDidLoad];
  self.searchBar.delegate = self;
  // Do any additional setup after loading the view.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  self.choosedUser = [self userAtIndex:indexPath.row];
  if (![self.choosedUser.userID
      isEqualToNumber:[QZBCurrentUser sharedInstance].user.userID]) {

    [self performSegueWithIdentifier:@"startChallengeSegue" sender:nil];
  } else {
    [self showAlertAboutUnabletoPlay];
  }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before
// navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  // Get the new view controller using [segue destinationViewController].
  // Pass the selected object to the new view controller.

  if ([segue.identifier isEqualToString:@"startChallengeSegue"]) {
    QZBProgressViewController *destinationVC = segue.destinationViewController;

    [destinationVC initSessionWithTopic:self.topic user:self.choosedUser];
  }
}

#pragma mark - custom init

- (void)setFriendsOwner:(id <QZBUserProtocol>)user
             andFriends:(NSArray *)friends
              gameTopic:(QZBGameTopic *)topic {
  self.topic = topic;
  self.currentFriends = [friends copy];
  [super setFriendsOwner:user andFriends:friends];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
  [self searchWithSearchBar:searchBar];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
  if (searchText.length == 0) {
    [super setFriendsOwner:nil andFriends:self.currentFriends];
  } else {
    [self searchWithSearchBar:searchBar];
  }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
  if (searchBar.text.length == 0) {

    [super setFriendsOwner:nil andFriends:self.currentFriends];
  }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
  if (searchBar.text.length == 0) {

    [super setFriendsOwner:nil andFriends:self.currentFriends];
  }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  [self.searchBar resignFirstResponder];
}

@end
