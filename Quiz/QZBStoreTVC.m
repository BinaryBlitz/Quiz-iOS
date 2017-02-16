//
//  QZBStoreTVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 25/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBStoreTVC.h"
#import "QZBQuizTopicIAPHelper.h"
#import "QZBStoreBoosterCell.h"
#import <StoreKit/StoreKit.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface QZBStoreTVC ()

@property (strong, nonatomic) NSArray *products;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSNumberFormatter *priceFormatter;

@end

@implementation QZBStoreTVC

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
    [self reload];
    //[self.refreshControl beginRefreshing];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];

    

    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(productPurchased:)
                                                 name:IAPHelperProductPurchasedNotification
                                               object:nil];
}

// 4
- (void)reload {
    _products = nil;
    
   // [self.tableView reloadData];
    
    [[QZBQuizTopicIAPHelper sharedInstance] getTopicIdentifiersFromServerOnSuccess:^{
        
        [[QZBQuizTopicIAPHelper sharedInstance]
         requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
             if (success) {
                 _products = products;
                 SKProduct *product = [products firstObject];
                 [_priceFormatter setLocale:product.priceLocale];
                 
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _products.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QZBStoreBoosterCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"boosterCell" forIndexPath:indexPath];

    SKProduct *product = (SKProduct *)_products[indexPath.row];
    cell.IAPName.text = product.localizedTitle;

    [self.priceFormatter setLocale:product.priceLocale];

    if ([[QZBQuizTopicIAPHelper sharedInstance] productPurchased:product.productIdentifier]) {
        [cell.purchaseButton setTitle:@"Куплено" forState:UIControlStateNormal];
        cell.purchaseButton.enabled = NO;

    } else {
        [cell.purchaseButton setTitle:[self.priceFormatter stringFromNumber:product.price]
                             forState:UIControlStateNormal];

        cell.purchaseButton.tag = indexPath.row;
        [cell.purchaseButton addTarget:self
                                action:@selector(buyButtonTapped:)
                      forControlEvents:UIControlEventTouchUpInside];
    }

    return cell;
}

- (void)buyButtonTapped:(id)sender {
    UIButton *buyButton = (UIButton *)sender;
    SKProduct *product = _products[buyButton.tag];

    NSLog(@"Buying %@...", product.productIdentifier);
    [[QZBQuizTopicIAPHelper sharedInstance] buyProduct:product];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)productPurchased:(NSNotification *)notification {
    NSString *productIdentifier = notification.object;
    [_products enumerateObjectsUsingBlock:^(SKProduct *product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            [self.tableView
                reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:idx inSection:0] ]
                      withRowAnimation:UITableViewRowAnimationFade];
            *stop = YES;
        }
    }];
}

- (void)restoreTapped:(id)sender {
    [[QZBQuizTopicIAPHelper sharedInstance] restoreCompletedTransactions];
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
@end
