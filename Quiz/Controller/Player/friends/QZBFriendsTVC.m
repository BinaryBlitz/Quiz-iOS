#import "QZBFriendsTVC.h"
#import "QZBFriendCell.h"
#import "QZBAnotherUser.h"
#import "QZBPlayerPersonalPageVC.h"
#import "QZBFriendsRequestsTVC.h"
#import "QZBFriendRequestManager.h"
#import "UIBarButtonItem+Badge.h"
#import <DFImageManager/DFImageManagerKit.h>

@interface QZBFriendsTVC ()

@property (strong, nonatomic) NSArray *friends;          // QZBAnotherUser
@property (strong, nonatomic) NSArray *friendsRequests;  // QZBAnotherUser
@property (strong, nonatomic) id <QZBUserProtocol> user;


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

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  if ([QZBFriendRequestManager sharedInstance].incoming.count == 0) {
    self.navigationItem.rightBarButtonItem = nil;
  }
}

#pragma mark - custom init

- (void)setFriendsOwner:(id <QZBUserProtocol>)user
                friends:(NSArray *)friends
        friendsRequests:(NSArray *)friendsRequest {
  if (friendsRequest && friendsRequest.count > 0) {

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 100, 20);
    [button addTarget:self action:@selector(showFriendsRequestsAction:) forControlEvents:UIControlEventTouchUpInside];

    NSString *requestTitle = @"Заявки";

    [button setTitle:requestTitle forState:UIControlStateNormal];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;

    self.friendsRequests = friendsRequest;
    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithCustomView:button];

    NSInteger count = 0;
    if (friendsRequest) {
      count = [self badgeNumberWithRequestFriends:friendsRequest];
    }
    if (count > 0) {
      button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
      //[NSString stringWithFormat:@"Заявки (%ld)", count];
      self.navigationItem.rightBarButtonItem.badgeValue =
          [NSString stringWithFormat:@"%ld", (long) count];
    }
  } else {
    // self.friendsRequestsButton.enabled = NO;
  }

  [self setFriendsOwner:user andFriends:friends];
}

- (NSInteger)badgeNumberWithRequestFriends:(NSArray *)arr {
  NSInteger count = [QZBFriendRequestManager sharedInstance].incoming.count;

  return count;
}




//- (void)setFriendsOwner:(id<QZBUserProtocol>)user friendsRequests:(NSArray *)friendsRequest {
//}

- (void)setFriendsOwner:(id <QZBUserProtocol>)user andFriends:(NSArray *)friends {
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

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([cell isKindOfClass:[QZBFriendCell class]]) {
    QZBFriendCell *c = (QZBFriendCell *) cell;
    QZBAnotherUser *user = self.friends[indexPath.row];

    DFMutableImageRequestOptions *options = [DFMutableImageRequestOptions new];

    options.allowsClipping = YES;
    options.userInfo = @{DFURLRequestCachePolicyKey: @(NSURLRequestReturnCacheDataElseLoad)};

    DFImageRequest *request = [DFImageRequest requestWithResource:user.imageURL
                                                       targetSize:CGSizeZero
                                                      contentMode:DFImageContentModeAspectFill
                                                          options:options];
    if (user.imageURL) {
      [[DFImageManager sharedManager] imageTaskForRequest:request completion:^(UIImage *_Nullable image, NSError *_Nullable error, DFImageResponse *_Nullable response, DFImageTask *_Nonnull imageTask) {
        UITableViewCell *cel =
            [tableView cellForRowAtIndexPath:indexPath];
        if (cel && [cel isKindOfClass:[QZBFriendCell class]]) {
          QZBFriendCell *c = (QZBFriendCell *) cel;
          c.userpicImageView.image = image;
        }
      }];
//      [[DFImageManager sharedManager]
//       requestImageForRequest:request
//       completion:^(UIImage *image, NSDictionary *info) {
//         dispatch_async(dispatch_get_main_queue(), ^{
//           UITableViewCell *cel =
//           [tableView cellForRowAtIndexPath:indexPath];
//           if (cel && [cel isKindOfClass:[QZBFriendCell class]]) {
//             QZBFriendCell *c = (QZBFriendCell *)cel;
//             c.userpicImageView.image = image;
//           }
//         });
//       }];
    } else {
      [c.userpicImageView setImage:[UIImage imageNamed:@"userpicStandart"]];
    }
  }
}

- (void)   tableView:(UITableView *)tableView
didEndDisplayingCell:(UITableViewCell *)cell
   forRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([cell isKindOfClass:[QZBFriendCell class]]) {
    QZBFriendCell *c = (QZBFriendCell *) cell;
    c.userpicImageView.image = [UIImage imageNamed:@"userpicStandart"];
  }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];

  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

  if (![cell isKindOfClass:[QZBFriendCell class]]) {
    return;
  }

  QZBFriendCell *friendCell = (QZBFriendCell *) cell;
  self.user = friendCell.user;

  [self performSegueWithIdentifier:@"showUserpage" sender:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

  return 71.0;
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
        (QZBFriendsRequestsTVC *) segue.destinationViewController;

    [destinationVC setFriendsOwner:self.user andFriends:self.friendsRequests];
  }
}

#pragma mark - actions

- (void)showFriendsRequestsAction:(id)sender {
  [self performSegueWithIdentifier:@"showFriendsRequests" sender:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

#pragma mark - support methods

- (id <QZBUserProtocol>)userAtIndex:(NSUInteger)userIndex {

  if (userIndex < self.friends.count) {
    return [self.friends objectAtIndex:userIndex];
  } else {
    return nil;
  }
}

@end
