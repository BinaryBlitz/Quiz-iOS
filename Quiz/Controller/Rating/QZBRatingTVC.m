#import "QZBRatingTVC.h"
#import "QZBRatingTVCell.h"
#import "QZBReloadingCell.h"
#import "QZBRatingPageVC.h"
#import "QZBUserInRating.h"
#import "UIColor+QZBProjectColors.h"

#import <DFImageManager/DFImageManagerKit.h>

NSString *const QZBNeedReloadRatingTableView = @"QZBNeedReloadRatingTableView";

@interface QZBRatingTVC () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *topRank;
@property (strong, nonatomic) NSArray *playerRank;

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

  self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 50)];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if ([self.refreshControl isRefreshing]) {
    return 0;
  }

  if (!self.topRank && !self.playerRank) {
    return 0;
  }
  if (self.topRank.count == 0 && self.playerRank.count == 0) {
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
  if (self.topRank.count == 0 && self.playerRank.count == 0) {
    QZBReloadingCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"activitiIndicatorCellIdentifier"];
    [cell.activityIndicator startAnimating];
    return cell;
  }

  UITableViewCell *resultCell = nil;

  if (indexPath.row == [self.topRank count] && [self shouldShowSeperator]) {
    resultCell = [tableView dequeueReusableCellWithIdentifier:@"ratingSeperator"];
  } else {
    QZBRatingTVCell *cell =
        (QZBRatingTVCell *) [tableView dequeueReusableCellWithIdentifier:@"ratingCell"];
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

- (void)   tableView:(UITableView *)tableView
didEndDisplayingCell:(UITableViewCell *)cell
   forRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([cell isKindOfClass:[QZBRatingTVCell class]]) {
    QZBRatingTVCell *c = (QZBRatingTVCell *) cell;
    c.userpic.image = [UIImage imageNamed:@"userpicStandart"];
  } else if ([cell isKindOfClass:[QZBReloadingCell class]]) {
    QZBReloadingCell *c = (QZBReloadingCell *) cell;
    [c.activityIndicator stopAnimating];
  }
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([cell isKindOfClass:[QZBRatingTVCell class]]) {
    QZBRatingTVCell *c = (QZBRatingTVCell *) cell;
    QZBUserInRating *user = c.user;

    if (user.imageURL) {
      DFImageRequest *request = [self requestFromURL:user.imageURL];
      [[DFImageManager sharedManager] imageTaskForRequest:request completion:^(UIImage *_Nullable image, NSError *_Nullable error, DFImageResponse *_Nullable response, DFImageTask *_Nonnull imageTask) {
        dispatch_async(dispatch_get_main_queue(), ^{
          UITableViewCell *cel =
              [tableView cellForRowAtIndexPath:indexPath];
          if (cel && [cel isKindOfClass:[QZBRatingTVCell class]]) {
            QZBRatingTVCell *c = (QZBRatingTVCell *) cel;
            c.userpic.image = image;
          }
        });
      }];
    } else {
      [c.userpic setImage:[UIImage imageNamed:@"userpicStandart"]];
    }
  }
}

- (DFImageRequest *)requestFromURL:(NSURL *)imageURL {
  DFMutableImageRequestOptions *options = [DFMutableImageRequestOptions new];

  options.allowsClipping = YES;
  options.userInfo = @{DFURLRequestCachePolicyKey: @(NSURLRequestReturnCacheDataElseLoad)};
  options.priority = NSOperationQueuePriorityHigh;

  DFImageRequest *request = [DFImageRequest requestWithResource:imageURL
                                                     targetSize:CGSizeZero
                                                    contentMode:DFImageContentModeAspectFill
                                                        options:options];
  return request;
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
    QZBRatingTVCell *userCell = (QZBRatingTVCell *) cell;
    QZBUserInRating *user = userCell.user;

    QZBRatingPageVC *vc = (QZBRatingPageVC *) self.parentViewController;

    [vc showUserPage:user];
  }
}

- (void)setPlayersRanksWithTop:(NSArray *)topArray playerArray:(NSArray *)playerArray {
  self.topRank = topArray;
  self.playerRank = playerArray;

  if (!playerArray && !topArray) {
    [self.refreshControl endRefreshing];
  }

  if (self.topRank.count == 0 && self.playerRank.count == 0) {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  } else {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.refreshControl endRefreshing];
    if (self.topRank.count > 0) {
      [self preheatFromUserArray:self.topRank];
    }
    if (self.playerRank.count > 0) {
      [self preheatFromUserArray:self.playerRank];
    }
  }

  [self.tableView reloadData];
}

- (void)reloadThisTable {
  [[NSNotificationCenter defaultCenter] postNotificationName:QZBNeedReloadRatingTableView
                                                      object:@(self.tableType)];
}

#pragma mark - preheat

- (void)preheatFromUserArray:(NSArray *)arr {
  NSMutableArray *tmpArr = [NSMutableArray array];
  for (QZBUserInRating *userInRating in arr) {
    if (userInRating.imageURL) {
      DFImageRequest *req = [self requestFromURL:userInRating.imageURL];
      [tmpArr addObject:req];
    }
  }
  if (tmpArr.count > 0) {
    [[DFImageManager sharedManager]
        startPreheatingImagesForRequests:[NSArray arrayWithArray:tmpArr]];
  }
}

@end
