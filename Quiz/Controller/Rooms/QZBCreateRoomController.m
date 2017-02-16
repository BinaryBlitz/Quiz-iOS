//
//  QZBCreateRoomController.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 29/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBCreateRoomController.h"

// model
#import "QZBServerManager.h"
#import "QZBGameTopic.h"

// UI
#import "UIViewController+QZBControllerCategory.h"
#import <SVProgressHUD.h>

// cells
#import "QZBTopicTableViewCell.h"
#import "QZBPlayerCountChooserCell.h"
#import "QZBRoomPasswordOnlyCell.h"


// controllers
#import "QZBRoomController.h"

// cell identifiers

NSString *const QZBPlayerCountChooserCellIdentifier     = @"playerCountChooserCell";
NSString *const QZBChooseTopicCellIdentifier            = @"chooseTopicCellIdentifier";
NSString *const QZBTopicCellIdentifier                  = @"topicCell";
NSString *const QZBChooseTopicDescriptionCellIdentifier = @"chooseTopicDescriptionCellIdentifier";
NSString *const QZBPasswordOnlyChooserCellIdentifier    = @"passwordOnlyChooserCellIdentifier";
NSString *const QZBPasswordInputCellIdentifier          = @"friendsOnlyChooserCellIdentifier";
NSString *const QZBCreateRoomCellIdentifier             = @"createRoomCellIdentifier";
NSString *const QZBEmptyCellIdentifier                  = @"emptyCellIdentifier";

// cell heigths

const CGFloat playersCountCellHeight            = 132.0;
const CGFloat topicChooserDescriptionCellHeight = 65.0;
const CGFloat topicCellHeight                   = 79.0;
const CGFloat createRoomCellHeight              = 56.0;

// segues

NSString *const QZBShowRoomCategoryChooserFromCreate = @"showRoomCategoryChooser";
NSString *const QZBShowCreatedRoomSegueIdentifier    = @"showCreatedRoom";

// messages
NSString *const QZBRoomCreatedMessage = @"Комната создана!";

@interface QZBCreateRoomController ()

@property (strong, nonatomic) QZBGameTopic *topic;
@property (assign, nonatomic) BOOL shoulShowPassword;

@property (strong, nonatomic) QZBRoom *room;

@property (strong, nonatomic) UISwitch *friendsOnlySwitch;
@property (strong, nonatomic) UISegmentedControl *usersCountSegmentControl;

@end

@implementation QZBCreateRoomController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initStatusbarWithColor:[UIColor blackColor]];
    self.title = @"Создание комнаты";
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.topic) {
        return 4;
    } else {
        return 6;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        QZBPlayerCountChooserCell *cell =
            [tableView dequeueReusableCellWithIdentifier:QZBPlayerCountChooserCellIdentifier];
        self.usersCountSegmentControl = cell.playersCountSegmentControll;
        return cell;
    } else if (indexPath.row == 1) {
        UITableViewCell *cell =
            [tableView dequeueReusableCellWithIdentifier:QZBChooseTopicDescriptionCellIdentifier];

        return cell;

    } else if (indexPath.row == 2) {
        if (self.topic) {
            QZBTopicTableViewCell *cell =
                [tableView dequeueReusableCellWithIdentifier:QZBTopicCellIdentifier];

            [cell initWithTopic:self.topic];

            return cell;
        } else {
            UITableViewCell *cell =
                [tableView dequeueReusableCellWithIdentifier:QZBChooseTopicCellIdentifier];

            return cell;
        }
    } else if (indexPath.row == 3) {
        QZBRoomPasswordOnlyCell *cell = [tableView
                                         dequeueReusableCellWithIdentifier:QZBPasswordInputCellIdentifier];
        
        self.friendsOnlySwitch = cell.passwordOnlySwitch;
        
        return cell;
        
    } else if (indexPath.row == [tableView numberOfRowsInSection:0] - 2) {
        UITableViewCell *cell =
            [tableView dequeueReusableCellWithIdentifier:QZBEmptyCellIdentifier];
        return cell;

    } else if (indexPath.row == [tableView numberOfRowsInSection:0] - 1) {
        UITableViewCell *cell =
            [tableView dequeueReusableCellWithIdentifier:QZBCreateRoomCellIdentifier];

        return cell;
    }

    else {
        return nil;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return playersCountCellHeight;
    } else if (indexPath.row == 1) {
        return topicChooserDescriptionCellHeight;
    } else if (indexPath.row == 2) {
        return topicCellHeight;
    } else {
        return 56;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.reuseIdentifier isEqualToString:QZBChooseTopicCellIdentifier] ||
        [cell.reuseIdentifier isEqualToString:QZBTopicCellIdentifier]) {
        // do segue to group chooser

        [self performSegueWithIdentifier:QZBShowRoomCategoryChooserFromCreate sender:nil];
    } else if ([cell.reuseIdentifier isEqualToString:QZBCreateRoomCellIdentifier]) {
        [self createRoom];
    }
}

#pragma mark - setting topic

- (void)setUserTopic:(QZBGameTopic *)topic {
    self.topic = topic;

    [self.tableView reloadData];
}
#pragma mark - room create

- (void)createRoom {
    if (self.topic) {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        //[SVProgressHUD ]
        
        NSNumber *usersCount =  @(self.usersCountSegmentControl.selectedSegmentIndex + 3);

        
        [[QZBServerManager sharedManager] POSTCreateRoomWithTopic:self.topic
                                                          private:self.friendsOnlySwitch.isOn
                                                             size:usersCount
                                                        OnSuccess:^(QZBRoom *room) {
                [SVProgressHUD showSuccessWithStatus:QZBRoomCreatedMessage];

                self.room = room;
                [self performSegueWithIdentifier:QZBShowCreatedRoomSegueIdentifier sender:nil];
            }
            onFailure:^(NSError *error, NSInteger statusCode) {
                [SVProgressHUD showErrorWithStatus:QZBNoInternetConnectionMessage];
            }];
    }
}

#pragma mark - ui

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


#pragma mark - navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:QZBShowCreatedRoomSegueIdentifier]) {
        QZBRoomController *destVC = (QZBRoomController *)segue.destinationViewController;

        [destVC initWithRoom:self.room];

    }
}

@end
