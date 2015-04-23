//
//  QZBStoreListTVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 14/03/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBStoreListTVC.h"

#import "QZBQuizTopicIAPHelper.h"
#import "QZBStoreBoosterCell.h"
#import "QZBMainBoosterCell.h"
#import "QZBDescriptionForHorizontalCell.h"
#import "UIViewController+QZBControllerCategory.h"
#import <StoreKit/StoreKit.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface QZBStoreListTVC ()

@property (strong, nonatomic) NSArray *products;

@property (strong, nonatomic) NSNumberFormatter *priceFormatter;

@property (strong, nonatomic) SKProduct *twiceBooster;
@property (strong, nonatomic) SKProduct *tripleBooster;
@property (strong, nonatomic) SKProduct *fiveTimesBooster;
@property (assign, nonatomic) BOOL needRelaod;
@property (assign, nonatomic) BOOL reloadInProgress;

@end

@implementation QZBStoreListTVC

//-(void)

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setNeedsStatusBarAppearanceUpdate];

    [self initStatusbarWithColor:[UIColor blackColor]];

    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Востановить"
                                         style:UIBarButtonItemStyleBordered
                                        target:self
                                        action:@selector(restoreTapped:)];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(reload)
                  forControlEvents:UIControlEventValueChanged];

    self.refreshControl.tintColor = [UIColor whiteColor];

    [self.tableView addSubview:self.refreshControl];

    self.tableView.backgroundColor = [UIColor veryDarkGreyColor];
    // [self reload];
    //[self.refreshControl beginRefreshing];
    //  [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];

    self.needRelaod = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    NSLog(@"viewVillAppear");

    if (self.needRelaod) {
      //  [self reload];
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    }

    [self.tableView reloadData];
    
    //[SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(productPurchased:)
                                                 name:IAPHelperProductPurchasedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(transactionFailed:)
                                                 name:IAPHelperProductPurchaseFailed
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    // self.products = nil;
    // self.twiceBooster = nil;
    // self.tripleBooster = nil;

    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setNeedRelaod:(BOOL)needRelaod{
    _needRelaod = needRelaod;
}

- (void)reload {
    // [self.tableView reloadData];

    if (!self.reloadInProgress) {
       // [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
        self.reloadInProgress = YES;
        //    _products = nil;
        
        _priceFormatter = [[NSNumberFormatter alloc] init];
        [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];

        [[QZBQuizTopicIAPHelper sharedInstance] getTopicIdentifiersFromServerOnSuccess:^{

            [[QZBQuizTopicIAPHelper sharedInstance]
                requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
                    if (success) {
                        // NSLog(@"products %@", products);

                        NSMutableArray *tmpproducts = [NSMutableArray arrayWithArray:products];
                        SKProduct *productForLocale = [products firstObject];
                        [_priceFormatter setLocale:productForLocale.priceLocale];
                        for (SKProduct *product in products) {
                            if ([product.productIdentifier
                                    isEqualToString:@"drumih.QZBQuizBattle.doubleBoosterTenDays"]) {
                                self.twiceBooster = product;
                                [tmpproducts removeObject:product];
                            } else if ([product.productIdentifier
                                           isEqualToString:
                                               @"drumih.QZBQuizBattle.tripleBoosterTenDays"]) {
                                self.tripleBooster = product;
                                [tmpproducts removeObject:product];
                            } else if ([product.productIdentifier
                                           isEqualToString:
                                               @"drumih.QZBQuizBattle.fiveTimesBoosterTenDays"]) {
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

        } onFailure:^(NSError *error, NSInteger statusCode) {
            [SVProgressHUD dismiss];
            [self.refreshControl endRefreshing];
            self.reloadInProgress = NO;

        }];
    }
}

#pragma mark - Table View

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 200.0;
    } else if (indexPath.row == 1) {
        return 32.0;
    } else {
        return 72.0;
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
            //            if ([[QZBQuizTopicIAPHelper sharedInstance]
            //                    productPurchased:self.twiceBooster.productIdentifier]) {
            //                [cell configButtonPurchased:cell.doubleBoosterButton];
            //
            //                int dayCount = [[QZBQuizTopicIAPHelper sharedInstance]
            //                                daysRemainingOnSubscriptionFromIdentifier:
            //                                self.twiceBooster.productIdentifier];
            //
            //                NSString *labelString = nil;
            //                if(dayCount>-1){
            //                    labelString = [self expirationDayCountFromInt:dayCount];
            //                }else{
            //                    labelString =
            //                    [self.priceFormatter stringFromNumber:self.twiceBooster.price];
            //                }
            //
            //                cell.doubleBoosterLabel.text = labelString;
            //
            //            } else {
            //
            //                cell.doubleBoosterLabel.text =
            //                [self.priceFormatter stringFromNumber:self.twiceBooster.price];
            //
            //
            //                [cell configButtonNotPurchased:cell.doubleBoosterButton];
            //
            //                cell.doubleBoosterButton.tag = 1;
            //                [cell.doubleBoosterButton addTarget:self
            //                                             action:@selector(buyTwiceBoosterButtonTapped:)
            //                                   forControlEvents:UIControlEventTouchUpInside];
            //            }
            //
            //            if ([[QZBQuizTopicIAPHelper sharedInstance]
            //                    productPurchased:self.tripleBooster.productIdentifier]) {
            //
            //                [cell configButtonPurchased:cell.tripleBoosterButton];
            //
            //                int dayCount = [[QZBQuizTopicIAPHelper sharedInstance]
            //                                daysRemainingOnSubscriptionFromIdentifier:
            //                                self.tripleBooster.productIdentifier];
            //
            //
            //                NSString *labelString = nil;
            //                if(dayCount>-1){
            //                    labelString = [self expirationDayCountFromInt:dayCount];
            //                }else{
            //                    labelString =
            //                    [self.priceFormatter stringFromNumber:self.tripleBooster.price];
            //                }
            //
            //                cell.tripleBoosterLabel.text = labelString;
            //
            //
            //
            //            } else {
            //
            //                [cell configButtonNotPurchased:cell.tripleBoosterButton];
            //
            //                cell.tripleBoosterLabel.text =
            //                [self.priceFormatter stringFromNumber:self.tripleBooster.price];
            //
            //                cell.tripleBoosterButton.tag = 2;
            //                [cell.tripleBoosterButton addTarget:self
            //                                             action:@selector(buyTripleBoosterButtonTapped:)
            //                                   forControlEvents:UIControlEventTouchUpInside];
            //            }
            //
            //            if ([[QZBQuizTopicIAPHelper sharedInstance]
            //                 productPurchased:self.fiveTimesBooster.productIdentifier]) {
            //
            //
            //                [cell configButtonPurchased:cell.fiveTimesBoosterButton];
            //
            //
            //                int dayCount = [[QZBQuizTopicIAPHelper sharedInstance]
            //                                daysRemainingOnSubscriptionFromIdentifier:
            //                                self.fiveTimesBooster.productIdentifier];
            //
            ////                if(dayCount>-1){
            ////                    cell.fiveTimesBoosterLabel.text = [self
            ///expirationDayCountFromInt:dayCount];
            ////                }else{
            ////                    cell.fiveTimesBoosterLabel.text =
            ////                    [self.priceFormatter
            ///stringFromNumber:self.fiveTimesBooster.price];
            ////                }
            //
            //                NSString *labelString = nil;
            //                if(dayCount>-1){
            //                    labelString = [self expirationDayCountFromInt:dayCount];
            //                }else{
            //                    labelString =
            //                    [self.priceFormatter
            //                    stringFromNumber:self.fiveTimesBooster.price];
            //                }
            //
            //                cell.fiveTimesBoosterLabel.text = labelString;
            //
            //            } else {
            //
            //                cell.fiveTimesBoosterLabel.text =
            //                [self.priceFormatter stringFromNumber:self.fiveTimesBooster.price];
            //
            //                [cell configButtonNotPurchased:cell.fiveTimesBoosterButton];
            //
            //                cell.fiveTimesBoosterButton.tag = 3;
            //                [cell.fiveTimesBoosterButton addTarget:self
            //                                             action:@selector(buyFiveTimesBoosterButtonTapped:)
            //                                   forControlEvents:UIControlEventTouchUpInside];
            //            }
            //
            //
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

    } else if (indexPath.row == 1) {
        QZBDescriptionForHorizontalCell *descrCell =
            [tableView dequeueReusableCellWithIdentifier:@"descriptionForHorizontal"];

        descrCell.descriptionLabel.text = @"Платные топики";
        descrCell.descriptionLabel.textColor = [UIColor whiteColor];
        descrCell.contentView.backgroundColor = [UIColor veryDarkGreyColor];

        return descrCell;

    } else {
        QZBStoreBoosterCell *cell =
            [tableView dequeueReusableCellWithIdentifier:@"topicCell" forIndexPath:indexPath];

        cell.contentView.backgroundColor = [UIColor veryDarkGreyColor];

        SKProduct *product = (SKProduct *)self.products[indexPath.row - 2];
        cell.IAPName.text = product.localizedTitle;

        [self.priceFormatter setLocale:product.priceLocale];

        if ([[QZBQuizTopicIAPHelper sharedInstance] productPurchased:product.productIdentifier]) {
            [cell.purchaseButton setTitle:@"Куплено" forState:UIControlStateNormal];
            cell.purchaseButton.enabled = NO;

        } else {
            [cell.purchaseButton setTitle:[self.priceFormatter stringFromNumber:product.price]
                                 forState:UIControlStateNormal];
            cell.purchaseButton.enabled = YES;

            cell.purchaseButton.tag = indexPath.row;
            [cell.purchaseButton addTarget:self
                                    action:@selector(buyButtonTapped:)
                          forControlEvents:UIControlEventTouchUpInside];
        }

        return cell;
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
    return [NSString stringWithFormat:@"Истекает через\n %d дней", dayCount];
}

#pragma mark - actions

- (UITableViewCell *)parentCellForView:(id)theView {
    id viewSuperView = [theView superview];
    while (viewSuperView != nil) {
        if ([viewSuperView isKindOfClass:[UITableViewCell class]]) {
            return (UITableViewCell *)viewSuperView;
        } else {
            viewSuperView = [viewSuperView superview];
        }
    }
    return nil;
}

- (void)buyProduct:(SKProduct *)product {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];

    NSLog(@"Buying %@...", product.productIdentifier);
    [[QZBQuizTopicIAPHelper sharedInstance] buyProduct:product];
}

- (void)buyButtonTapped:(id)sender {
    UITableViewCell *cell = [self parentCellForView:sender];
    if (cell != nil) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

        // UIButton *buyButton = (UIButton *)sender;
        SKProduct *product = _products[indexPath.row - 2];

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
    //    [_products enumerateObjectsUsingBlock:^(SKProduct *product, NSUInteger idx, BOOL *stop) {
    //        if ([product.productIdentifier isEqualToString:productIdentifier]) {
    //            //            [self.tableView
    //            //                reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:idx+1
    //            //                inSection:0] ]
    //            //                      withRowAnimation:UITableViewRowAnimationFade];
    //            [self.tableView reloadData];
    //            *stop = YES;
    //        }
    //    }];

    [SVProgressHUD dismiss];
}

- (void)transactionFailed:(NSNotification *)notification {
    [SVProgressHUD dismiss];
}

- (void)restoreTapped:(id)sender {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[QZBQuizTopicIAPHelper sharedInstance] restoreCompletedTransactions];
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
