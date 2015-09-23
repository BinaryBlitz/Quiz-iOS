//
//  QZBRatingVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 06/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRatingTVC.h"
#import "QZBRatingTVCell.h"
#import "QZBReloadingCell.h"
#import "UIImageView+AFNetworking.h"
#import "QZBRatingPageVC.h"
#import "QZBUserInRating.h"
#import "QZBCurrentUser.h"
#import "QZBUser.h"
#import "UIColor+QZBProjectColors.h"

#import <DFImageManager/DFImageManagerKit.h>
#import <DFImageManagerKit+UI.h>

NSString *const QZBNeedReloadRatingTableView = @"QZBNeedReloadRatingTableView";
//#import <DFImageManager/DFImageManager.h>
//#import <DFImageManager/DFImageRequestOptions.h>
//#import <DFImageManager/DFURLImageFetcher.h>
//#import <DFImageManager/DFImageRequest.h>
//#import <DFImageManager/DFImageView.h>

@interface QZBRatingTVC () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *topRank;     // QZBUserInRating
@property (strong, nonatomic) NSArray *playerRank;  // QZBUserInRating

@end

@implementation QZBRatingTVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.multipleTouchEnabled = NO;
    
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(reloadThisTable)
                  forControlEvents:UIControlEventValueChanged];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self.ratingTableView reloadData];

    if ([self.parentViewController isKindOfClass:[QZBRatingPageVC class]]) {
        QZBRatingPageVC *pageVC = (QZBRatingPageVC *)self.parentViewController;
        pageVC.expectedType = self.tableType;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if([self.refreshControl isRefreshing]) {
        return 0;
    }
    
    if(!self.topRank && !self.playerRank){
        return 0;
    }
        if(self.topRank.count == 0 && self.playerRank.count == 0) {
            return 1;
        }

    NSInteger result = 0;

    if (self.topRank) {
        result += [self.topRank count];
    }

    if (self.playerRank) {
        result += [self.playerRank count];
    }
    if ([self shouldShowSeperator]) {
        result++;
    }

    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        if(self.topRank.count == 0 && self.playerRank.count == 0){
            QZBReloadingCell *cell = [tableView
            dequeueReusableCellWithIdentifier:@"activitiIndicatorCellIdentifier"];
            [cell.activityIndicator startAnimating];
            return cell;
        }

    UITableViewCell *resultCell = nil;

    if (indexPath.row == [self.topRank count] && [self shouldShowSeperator]) {
        resultCell = [tableView dequeueReusableCellWithIdentifier:@"ratingSeperator"];
    } else {
        QZBRatingTVCell *cell =
            (QZBRatingTVCell *)[tableView dequeueReusableCellWithIdentifier:@"ratingCell"];
        QZBUserInRating *user = nil;

        if (indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2) {
            cell.myMedalView.alpha = 1.0;
            if (indexPath.row == 0) {
                cell.myMedalView.backgroundColor = [UIColor goldColor];
            } else if (indexPath.row == 1) {
                cell.myMedalView.backgroundColor = [UIColor silverColor];
            } else if (indexPath.row == 2) {
                cell.myMedalView.backgroundColor = [UIColor bronzeColor];
            }
        } else {
            cell.myMedalView.backgroundColor = [UIColor clearColor];
        }

        if (indexPath.row < [self.topRank count]) {
            user = self.topRank[indexPath.row];
        } else {
            if ([self shouldShowSeperator]) {
                user = self.playerRank[indexPath.row - [self.topRank count] - 1];
            } else {
                user = self.playerRank[indexPath.row - [self.topRank count]];
            }
        }

        [self setCell:cell user:user];
        resultCell = cell;
    }
    return resultCell;
}

- (void)setCell:(QZBRatingTVCell *)cell user:(QZBUserInRating *)user {
    [cell setCellWithUser:user];
}

- (void)tableView:(UITableView *)tableView
    didEndDisplayingCell:(UITableViewCell *)cell
       forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[QZBRatingTVCell class]]) {
                QZBRatingTVCell *c = (QZBRatingTVCell *)cell;
                c.userpic.image = [UIImage imageNamed:@"userpicStandart"];
    } else if ([cell isKindOfClass:[QZBReloadingCell class]]){
        QZBReloadingCell *c = (QZBReloadingCell *)cell;
        [c.activityIndicator stopAnimating];
    }
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[QZBRatingTVCell class]]) {
        QZBRatingTVCell *c = (QZBRatingTVCell *)cell;
        QZBUserInRating *user = c.user;
        DFImageRequestOptions *options = [DFImageRequestOptions new];
        options.allowsClipping = YES;

        options.userInfo = @{ DFURLRequestCachePolicyKey : @(NSURLRequestReturnCacheDataElseLoad) };

        DFImageRequest *request = [DFImageRequest requestWithResource:user.imageURL
                                                           targetSize:CGSizeZero
                                                          contentMode:DFImageContentModeAspectFill
                                                              options:options];

        if (user.imageURL) {
            [[DFImageManager sharedManager]
                requestImageForRequest:request
                            completion:^(UIImage *image, NSDictionary *info) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    UITableViewCell *cel =
                                        [tableView cellForRowAtIndexPath:indexPath];
                                    if (cel && [cel isKindOfClass:[QZBRatingTVCell class]]) {
                                        QZBRatingTVCell *c = (QZBRatingTVCell *)cel;
                                        c.userpic.image = image;
                                    }
                                });


                            }];
        } else {
            [c.userpic setImage:[UIImage imageNamed:@"userpicStandart"]];
        }

        //  [self setCell:cell user:user indexPath:indexPath tableView:tableView];
    }
}
//-(void)setUserCell:(QZBRatingTVCell *)cell

- (BOOL)shouldShowSeperator {
    if (self.playerRank) {
        QZBUserInRating *user = [self.playerRank firstObject];
        if (user.position <= 21) {
            return NO;
        }
    }
    if (!self.topRank || !self.playerRank) {
        return NO;
    }
    return YES;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    if (![cell isKindOfClass:[QZBRatingTVCell class]]) {
        return;
    }

    if ([self.parentViewController isKindOfClass:[QZBRatingPageVC class]]) {
        QZBRatingTVCell *userCell = (QZBRatingTVCell *)cell;
        QZBUserInRating *user = userCell.user;

        QZBRatingPageVC *vc = (QZBRatingPageVC *)self.parentViewController;

        [vc showUserPage:user];
    }
}

- (void)setPlayersRanksWithTop:(NSArray *)topArray playerArray:(NSArray *)playerArray {
    self.topRank = topArray;
    self.playerRank = playerArray;
    
    if(!playerArray && !topArray) {
        [self.refreshControl endRefreshing];
    }
    
    if(self.topRank.count == 0 && self.playerRank.count == 0){
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    } else {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [self.refreshControl endRefreshing];
    }

    [self.tableView reloadData];
}

-(void)reloadThisTable {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:QZBNeedReloadRatingTableView
                                                        object:@(self.tableType)];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before
navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
