#import "QZBRoomListTVC.h"
#import "QZBServerManager.h"
#import <SVProgressHUD.h>
#import "QZBRoomCell.h"
#import "QZBRoomController.h"
#import "UIViewController+QZBControllerCategory.h"
#import "QZBRoom.h"

// Cell identifiers
NSString *const QZBRoomCellIdentifier = @"QZBRoomCellIdentifier";
NSString *const QZBCreateRoomCellIdentifierInRoomList = @"enterRoomCellIdentifier";

// Segues
NSString *const QZBShowRoomSegueIdentifier = @"showRoomSegueIdentifier";
NSString *const QZBRoomCreationSegueIdentifier = @"roomCreationSegueIdentifier";

// Title
NSString *const QZBCurrentTitle = @"Комнаты";

// Messages
NSString *const QZBNothingFindedMessage = @"Ничего не найдено";

@interface QZBRoomListTVC ()

@property (strong, nonatomic) NSArray *rooms;
@property (strong, nonatomic) QZBRoom *choosedRoom;

@end

@implementation QZBRoomListTVC

- (void)viewDidLoad {
  [super viewDidLoad];
  self.searchBar.delegate = self;
  self.refreshControl = [[UIRefreshControl alloc] init];
  // self.refreshControl.tintColor = [UIColor whiteColor];
  [self.refreshControl addTarget:self
                          action:@selector(reloadRooms)
                forControlEvents:UIControlEventValueChanged];

  self.refreshControl.tintColor = [UIColor whiteColor];
  [self initStatusbarWithColor:[UIColor blackColor]];
  [self addBarButtonRight];
  self.title = QZBCurrentTitle;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.tabBarController.tabBar.hidden = NO;
  [self reloadRooms];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:QZBShowRoomSegueIdentifier]) {
    QZBRoomController *destVC = segue.destinationViewController;

    [destVC initWithRoom:self.choosedRoom];
    self.choosedRoom = nil;
  }
}

#pragma mark - table view
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.rooms.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 0) {
    UITableViewCell *cell = [tableView
        dequeueReusableCellWithIdentifier:QZBCreateRoomCellIdentifierInRoomList];

    return cell;
  }

  QZBRoomCell *cell = [tableView dequeueReusableCellWithIdentifier:QZBRoomCellIdentifier];
  QZBRoom *room = self.rooms[indexPath.row - 1];

  [cell configureCellWithRoom:room];

  return cell;
}

#pragma mark - UITableViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  [self.searchBar resignFirstResponder];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 0) {
    [self createRoom];
    return;
  }

  QZBRoom *r = self.rooms[indexPath.row - 1];

  self.choosedRoom = r;
  [self performSegueWithIdentifier:QZBShowRoomSegueIdentifier sender:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

  if (indexPath.row == 0) {
    return 80;
  }
  QZBRoom *r = self.rooms[indexPath.row - 1];
  const CGFloat shortCellHeight = 70.0;
  const CGFloat longCellHeight = 140.0;
  if (r.participants.count <= 2) {
    return shortCellHeight;
  } else {
    return longCellHeight;
  }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
  NSString *stringToSearch = searchBar.text;

  NSInteger val = [stringToSearch integerValue];

  [[QZBServerManager sharedManager] GETRoomWithID:@(val)
                                        OnSuccess:^(QZBRoom *room) {

                                          self.rooms = @[room];
                                          [self.tableView reloadData];
                                        }
                                        onFailure:^(NSError *error, NSInteger statusCode) {
                                          [SVProgressHUD showErrorWithStatus:QZBNothingFindedMessage];
                                        }];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
  if ([searchText isEqualToString:@""]) {
    [self reloadRooms];
  }
}

#pragma mark - actions

- (void)reloadRooms {
  [self.refreshControl beginRefreshing];

  [[QZBServerManager sharedManager] GETAllRoomsOnSuccess:^(NSArray *rooms) {

    [self.refreshControl endRefreshing];
    self.rooms = rooms;
    [self.tableView reloadData];
  }                                            onFailure:^(NSError *error, NSInteger statusCode) {

    [self.refreshControl endRefreshing];

    if (statusCode == 0) {
      [SVProgressHUD showErrorWithStatus:QZBNoInternetConnectionMessage];
    }
  }];
}

- (void)createRoom {
  self.choosedRoom = nil;
  [self performSegueWithIdentifier:QZBRoomCreationSegueIdentifier sender:nil];
}

#pragma mark - support methods

- (void)addBarButtonRight {
  self.navigationItem.rightBarButtonItem =
      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                    target:self
                                                    action:@selector(reloadRooms)];
}

@end
