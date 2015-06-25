//
//  QZBRoomListTVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 16/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRoomListTVC.h"
#import "QZBServerManager.h"
#import <SVProgressHUD.h>
#import "QZBRoomCell.h"
#import "QZBRoomController.h"
#import "UIViewController+QZBControllerCategory.h"
// cell identifiers
NSString *const QZBRoomCellIdentifier = @"QZBRoomCellIdentifier";

// segues
NSString *const QZBShowRoomSegueIdentifier = @"showRoomSegueIdentifier";

// title

NSString *const QZBCurrentTitle = @"Комнаты";

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

    [self initStatusbarWithColor:[UIColor blackColor]];

    [self addBarButtonRight];

    self.title = QZBCurrentTitle;

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
    return self.rooms.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QZBRoomCell *cell = [tableView dequeueReusableCellWithIdentifier:QZBRoomCellIdentifier];
    QZBRoom *room = self.rooms[indexPath.row];

    [cell configureCellWithRoom:room];

    return cell;
}

#pragma mark - UITableViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    QZBRoom *r = self.rooms[indexPath.row];

    self.choosedRoom = r;
    [self performSegueWithIdentifier:QZBShowRoomSegueIdentifier sender:nil];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *stringToSearch = searchBar.text;

    NSInteger val = [stringToSearch integerValue];

    //  NSNumber *number = @([stringToSearch intValue]);

    NSLog(@"num to search %ld", val);

    //
    [[QZBServerManager sharedManager] GETRoomWithID:@(val)
        OnSuccess:^(QZBRoom *room) {

            self.rooms = @[ room ];
            [self.tableView reloadData];

        }
        onFailure:^(NSError *error, NSInteger statusCode) {
            [SVProgressHUD showErrorWithStatus:@"Ничего не найдено"];

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

    } onFailure:^(NSError *error, NSInteger statusCode) {

        [self.refreshControl endRefreshing];

        if (statusCode == 0) {
            [SVProgressHUD showErrorWithStatus:QZBNoInternetConnectionMessage];
        }
    }];
}

- (void)createRoom {
    //
    //    [[QZBServerManager sharedManager] POSTCreateRoomOnSuccess:^(QZBRoom *room) {
    //
    //    } onFailure:^(NSError *error, NSInteger statusCode) {
    //
    //    }];
    self.choosedRoom = nil;
    [self performSegueWithIdentifier:QZBShowRoomSegueIdentifier sender:nil];
}

//-(void)showCategoryChooser{
//
//    [self performSegueWithIdentifier:QZBShowRoomCategoryChooser sender:nil];
//}

#pragma mark - support methods

- (void)addBarButtonRight {
    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                      target:self
                                                      action:@selector(createRoom)];
}

@end
