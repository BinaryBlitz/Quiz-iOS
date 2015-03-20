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
#import <StoreKit/StoreKit.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface QZBStoreListTVC ()

@property (strong, nonatomic) NSArray *products;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSNumberFormatter *priceFormatter;

@property (strong, nonatomic) SKProduct *twiceBooster;
@property (strong, nonatomic) SKProduct *tripleBooster;

@end

@implementation QZBStoreListTVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setNeedsStatusBarAppearanceUpdate];

    _priceFormatter = [[NSNumberFormatter alloc] init];
    [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];

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

    [self.tableView addSubview:self.refreshControl];
    // [self reload];
    //[self.refreshControl beginRefreshing];
  //  [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    NSLog(@"viewVillAppear");

    [self reload];

    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
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
    self.products = nil;
    self.twiceBooster = nil;
    self.tripleBooster = nil;
    
    
    
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reload {
    _products = nil;

    // [self.tableView reloadData];

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
                                isEqualToString:@"drumih.QZBQuizBattle.twiceBooster"]) {
                            self.twiceBooster = product;
                            [tmpproducts removeObject:product];
                        } else if ([product.productIdentifier
                                       isEqualToString:@"drumih.QZBQuizBattle.tripleBooster"]) {
                            self.tripleBooster = product;
                            [tmpproducts removeObject:product];
                        }
                    }
                    self.products = [NSArray arrayWithArray:tmpproducts];

                    [self.tableView reloadData];
                    // [SVProgressHUD dismiss];
                }

                [SVProgressHUD dismiss];
                [self.refreshControl endRefreshing];
            }];

    } onFailure:^(NSError *error, NSInteger statusCode) {
        [SVProgressHUD dismiss];
        [self.refreshControl endRefreshing];

    }];
}

#pragma mark - Table View

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 200.0;
    } else {
        return 44.0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _products.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        QZBMainBoosterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"boosterCell"];

        if (self.twiceBooster && self.tripleBooster) {
            if ([[QZBQuizTopicIAPHelper sharedInstance]
                    productPurchased:self.twiceBooster.productIdentifier]) {
                [cell.doubleBoosterButton setTitle:@"Куплено" forState:UIControlStateNormal];
                cell.doubleBoosterButton.enabled = NO;

            } else {
                [cell.doubleBoosterButton
                    setTitle:[self.priceFormatter stringFromNumber:self.twiceBooster.price]
                    forState:UIControlStateNormal];
                cell.doubleBoosterButton.enabled = YES;

                cell.doubleBoosterButton.tag = 1;
                [cell.doubleBoosterButton addTarget:self
                                             action:@selector(buyTwiceBoosterButtonTapped:)
                                   forControlEvents:UIControlEventTouchUpInside];
            }
            
            if ([[QZBQuizTopicIAPHelper sharedInstance]
                 productPurchased:self.tripleBooster.productIdentifier]) {
                [cell.tripleBoosterCell setTitle:@"Куплено" forState:UIControlStateNormal];
                cell.tripleBoosterCell.enabled = NO;
                
            } else {
                [cell.tripleBoosterCell
                 setTitle:[self.priceFormatter stringFromNumber:self.twiceBooster.price]
                 forState:UIControlStateNormal];
                cell.tripleBoosterCell.enabled = YES;
                
                cell.tripleBoosterCell.tag = 2;
                [cell.tripleBoosterCell addTarget:self
                                             action:@selector(buyTripleBoosterButtonTapped:)
                                   forControlEvents:UIControlEventTouchUpInside];
            }

        }

        return cell;

    } else {
        QZBStoreBoosterCell *cell =
            [tableView dequeueReusableCellWithIdentifier:@"topicCell" forIndexPath:indexPath];

        SKProduct *product = (SKProduct *)self.products[indexPath.row - 1];
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

-(void)buyProduct:(SKProduct *)product{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    NSLog(@"Buying %@...", product.productIdentifier);
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

-(void)buyTwiceBoosterButtonTapped:(id)sender{
    
    [self buyProduct:self.twiceBooster];
    
    
}

-(void)buyTripleBoosterButtonTapped:(id)sender{
    [self buyProduct:self.tripleBooster];
}



- (void)productPurchased:(NSNotification *)notification {
    NSString *productIdentifier = notification.object;
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
    [[QZBQuizTopicIAPHelper sharedInstance] restoreCompletedTransactions];
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
