#import "QZBStoreListTVC.h"

#import "QZBQuizTopicIAPHelper.h"
#import "QZBStoreBoosterCell.h"
#import "QZBMainBoosterCell.h"
#import "UIViewController+QZBControllerCategory.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "NSString+QZBStringCategory.h"
#import "QZBServerManager.h"
#import "MagicalRecord/MagicalRecord.h"
#import "QZBGameTopic.h"

#import <DDLog.h>

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

NSString *const QZBShowAllPaidTopicsSegueIdentifier = @"QZBShowAllPaidTopicsSegueIdentifier";

@interface QZBStoreListTVC ()

@property (strong, nonatomic) NSArray *products;

@property (strong, nonatomic) NSNumberFormatter *priceFormatter;

@property (strong, nonatomic) SKProduct *twiceBooster;
@property (strong, nonatomic) SKProduct *tripleBooster;
@property (strong, nonatomic) SKProduct *fiveTimesBooster;
@property (assign, nonatomic) BOOL needRelaod;
@property (assign, nonatomic) BOOL reloadInProgress;

@property (strong, nonatomic) NSArray *paidTopics;

@end

@implementation QZBStoreListTVC

- (void)viewDidLoad {
  [super viewDidLoad];

  [self setNeedsStatusBarAppearanceUpdate];

  [self initStatusbarWithColor:[UIColor blackColor]];

  self.tableView.dataSource = self;
  self.tableView.delegate = self;

  self.refreshControl = [[UIRefreshControl alloc] init];
  [self.refreshControl addTarget:self
                          action:@selector(reload)
                forControlEvents:UIControlEventValueChanged];

  self.refreshControl.tintColor = [UIColor whiteColor];

  [self.tableView addSubview:self.refreshControl];

  self.tableView.backgroundColor = [UIColor veryDarkGreyColor];

  self.needRelaod = YES;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  if (self.needRelaod) {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    [self reload];//TEST
  }

  [self.tableView reloadData];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(productPurchased:)
                                               name:IAPHelperProductPurchasedNotification
                                             object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(transactionFailed:)
                                               name:IAPHelperProductPurchaseFailed
                                             object:nil];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(transactionFailed:)
                                               name:IAPHelperProductRestoreFinished
                                             object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {

  [super viewWillDisappear:animated];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setNeedRelaod:(BOOL)needRelaod {
  _needRelaod = needRelaod;
}

- (void)reload {
  if (!self.reloadInProgress) {
    self.reloadInProgress = YES;

    _priceFormatter = [[NSNumberFormatter alloc] init];
    [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];

    [[QZBQuizTopicIAPHelper sharedInstance] getTopicIdentifiersFromServerOnSuccess:^{

      [[QZBQuizTopicIAPHelper sharedInstance]
          requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
            if (success) {

              NSMutableArray *tmpproducts = [NSMutableArray arrayWithArray:products];
              SKProduct *productForLocale = [products firstObject];
              [_priceFormatter setLocale:productForLocale.priceLocale];
              for (SKProduct *product in products) {
                if ([product.productIdentifier
                    isEqualToString:@"ru.binaryblitz.1vs1.doubleBoosterTenDays"]) {
                  self.twiceBooster = product;
                  [tmpproducts removeObject:product];
                } else if ([product.productIdentifier
                    isEqualToString:
                        @"ru.binaryblitz.1vs1.tripleBoosterTenDays"]) {
                  self.tripleBooster = product;
                  [tmpproducts removeObject:product];
                } else if ([product.productIdentifier
                    isEqualToString:
                        @"ru.binaryblitz.1vs1.fiveTimesBoosterTenDays"]) {
                  self.fiveTimesBooster = product;
                  [tmpproducts removeObject:product];
                }
              }
              self.products = [NSArray arrayWithArray:tmpproducts];

              [self.tableView reloadData];
              // [SVProgressHUD dismiss];

              self.needRelaod = NO;
            }

            self.reloadInProgress = NO;
            [SVProgressHUD dismiss];
            [self.refreshControl endRefreshing];
          }];
    }                                                                    onFailure:^(NSError *error, NSInteger statusCode) {

      DDLogInfo(@"status code %ld", (long) statusCode);

      if (statusCode == 0) {
        [SVProgressHUD showErrorWithStatus:QZBNoInternetConnectionMessage];
      }

      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
      });

      // [SVProgressHUD dismiss];
      [self.refreshControl endRefreshing];
      self.reloadInProgress = NO;
    }];
  }
}

#pragma mark - Table View

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 0) {
    return 270.0;
  } else if (indexPath.row == 1) {
    return 186.0;
  } else {
    return 70.0;
  }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _products.count + 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 0) {
    QZBMainBoosterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"boosterCell"];

    if (self.twiceBooster && self.tripleBooster && self.fiveTimesBooster) {

      [self configureBooserCell:cell
                          label:cell.doubleBoosterLabel
                         button:cell.doubleBoosterButton
                    fromProfuct:self.twiceBooster];
      [self configureBooserCell:cell
                          label:cell.tripleBoosterLabel
                         button:cell.tripleBoosterButton
                    fromProfuct:self.tripleBooster];
      [self configureBooserCell:cell
                          label:cell.fiveTimesBoosterLabel
                         button:cell.fiveTimesBoosterButton
                    fromProfuct:self.fiveTimesBooster];
    }

    return cell;
  } else
  if (indexPath.row < [tableView numberOfRowsInSection:0] - 1) {
    QZBStoreBoosterCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"topicCell" forIndexPath:indexPath];
    cell.purchaseButton.layer.cornerRadius = 5.0;
    cell.purchaseButton.layer.masksToBounds = YES;

    cell.contentView.backgroundColor = [UIColor veryDarkGreyColor];

    SKProduct *product = (SKProduct *) self.products[indexPath.row - 1];
    cell.IAPName.text = product.localizedTitle;

    [self.priceFormatter setLocale:product.priceLocale];

    if ([[QZBQuizTopicIAPHelper sharedInstance] productPurchased:product.productIdentifier]) {
      [cell.purchaseButton setTitle:@"Куплено" forState:UIControlStateNormal];
      cell.purchaseButton.backgroundColor = [UIColor lightGrayColor];
      cell.purchaseButton.enabled = NO;
    } else {
      cell.allTopicPurchaseDescriptionLabel.text = [NSString
          stringWithFormat:@"Более %@ тем за %@",
                           self.paidCount,
                           [self.priceFormatter stringFromNumber:product.price]];
      cell.purchaseButton.enabled = YES;

      cell.purchaseButton.tag = indexPath.row;
      [cell.purchaseButton addTarget:self
                              action:@selector(buyButtonTapped:)
                    forControlEvents:UIControlEventTouchUpInside];
    }

    return cell;
  } else {
    UITableViewCell *cell = [tableView
        dequeueReusableCellWithIdentifier:@"restoreIdentifier"];

    return cell;
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  if ([cell.reuseIdentifier isEqualToString:@"restoreIdentifier"]) {
    [self restoreTapped:nil];
  }
}

- (void)configureBooserCell:(QZBMainBoosterCell *)cell
                      label:(UILabel *)label
                     button:(UIButton *)button
                fromProfuct:(SKProduct *)product {
  if ([[QZBQuizTopicIAPHelper sharedInstance] productPurchased:product.productIdentifier]) {

    [cell configButtonPurchased:button];

    int dayCount = [[QZBQuizTopicIAPHelper sharedInstance]
        daysRemainingOnSubscriptionFromIdentifier:product.productIdentifier];

    NSString *labelString = nil;
    if (dayCount > -1) {
      labelString = [self expirationDayCountFromInt:dayCount];
    } else {
      labelString = [self.priceFormatter stringFromNumber:product.price];
    }

    label.text = labelString;
  } else {
    label.text = [self.priceFormatter stringFromNumber:product.price];

    [cell configButtonNotPurchased:button];

    int tag = 0;
    if ([product isEqual:self.twiceBooster]) {
      tag = 2;
    } else if ([product isEqual:self.tripleBooster]) {
      tag = 3;
    } else if ([product isEqual:self.fiveTimesBooster]) {
      tag = 5;
    }

    button.tag = tag;
    [button addTarget:self
               action:@selector(buyBoosterButtonTapped:)
     forControlEvents:UIControlEventTouchUpInside];
  }
}

- (NSString *)expirationDayCountFromInt:(int)dayCount {

  NSString *day = [NSString endOfDayWordFromNumber:dayCount];
  return [NSString stringWithFormat:@"Истекает через\n %d %@", dayCount, day];
}

#pragma mark - actions

- (UITableViewCell *)parentCellForView:(id)theView {
  id viewSuperView = [theView superview];
  while (viewSuperView != nil) {
    if ([viewSuperView isKindOfClass:[UITableViewCell class]]) {
      return (UITableViewCell *) viewSuperView;
    } else {
      viewSuperView = [viewSuperView superview];
    }
  }
  return nil;
}

- (void)buyProduct:(SKProduct *)product {
  [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];

  [[QZBQuizTopicIAPHelper sharedInstance] buyProduct:product];
}

- (void)buyButtonTapped:(id)sender {
  UITableViewCell *cell = [self parentCellForView:sender];
  if (cell != nil) {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    // UIButton *buyButton = (UIButton *)sender;
    SKProduct *product = _products[indexPath.row - 1];

    [self buyProduct:product];
  }
}

- (void)buyTwiceBoosterButtonTapped:(id)sender {
  [self buyProduct:self.twiceBooster];
}

- (void)buyTripleBoosterButtonTapped:(id)sender {
  [self buyProduct:self.tripleBooster];
}

- (void)buyFiveTimesBoosterButtonTapped:(id)sender {
  [self buyProduct:self.fiveTimesBooster];
}

- (void)buyBoosterButtonTapped:(UIButton *)sender {
  if (sender.tag == 2) {
    [self buyTwiceBoosterButtonTapped:nil];
  } else if (sender.tag == 3) {
    [self buyTripleBoosterButtonTapped:nil];
  } else if (sender.tag == 5) {
    [self buyFiveTimesBoosterButtonTapped:nil];
  }
}

- (void)productPurchased:(NSNotification *)notification {
  ///  NSString *productIdentifier = notification.object;
  [self.tableView reloadData];

  [SVProgressHUD dismiss];
}

- (void)transactionFailed:(NSNotification *)notification {
  [SVProgressHUD dismiss];
}

- (void)restoreTapped:(id)sender {
  [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
  [[QZBQuizTopicIAPHelper sharedInstance] restoreCompletedTransactions];
}

- (IBAction)showAllPaidTopicsAction:(UIButton *)sender {
  [self showAllPaidTopics];
}

- (void)showAllPaidTopics {
  [self performSegueWithIdentifier:QZBShowAllPaidTopicsSegueIdentifier sender:nil];
}

- (void)addBarButtonRight {
  self.navigationItem.rightBarButtonItem =
      [[UIBarButtonItem alloc] initWithTitle:@"Вопросы"
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(showAllPaidTopics)];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

#pragma mark - lazy

- (NSNumber *)paidCount {
  //REDO
  return @(self.paidTopics.count - 1);
}

- (NSArray *)paidTopics {
  if (!_paidTopics) {
    _paidTopics = [QZBGameTopic MR_findByAttribute:@"paid" withValue:@(YES)];
  }

  return _paidTopics;
}

@end
