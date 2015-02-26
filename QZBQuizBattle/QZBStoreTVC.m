//
//  QZBStoreTVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 25/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBStoreTVC.h"
#import "QZBQuizIAPHelper.h"
#import <StoreKit/StoreKit.h>

@interface QZBStoreTVC ()

@property (strong, nonatomic) NSArray *products;
@property (strong, nonatomic) NSNumberFormatter *priceFormatter;

@end

@implementation QZBStoreTVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(reload)
                  forControlEvents:UIControlEventValueChanged];
    [self reload];
    [self.refreshControl beginRefreshing];

    _priceFormatter = [[NSNumberFormatter alloc] init];
    [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];

    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Востановить"
                                         style:UIBarButtonItemStyleBordered
                                        target:self
                                        action:@selector(restoreTapped:)];
}

// 4
- (void)reload {
    _products = nil;
    [self.tableView reloadData];
    [[QZBQuizIAPHelper sharedInstance]
        requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
            if (success) {
                _products = products;
                [self.tableView reloadData];
            }
            [self.refreshControl endRefreshing];
        }];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// 5
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _products.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"boosterCell" forIndexPath:indexPath];

    SKProduct *product = (SKProduct *)_products[indexPath.row];
    cell.textLabel.text = product.localizedTitle;

    [_priceFormatter setLocale:product.priceLocale];
    cell.detailTextLabel.text = [_priceFormatter stringFromNumber:product.price];

    if ([[QZBQuizIAPHelper sharedInstance] productPurchased:product.productIdentifier]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.accessoryView = nil;
    } else {
        UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeSystem];
        buyButton.frame = CGRectMake(0, 0, 72, 37);
        [buyButton setTitle:@"Buy" forState:UIControlStateNormal];
        buyButton.tag = indexPath.row;
        [buyButton addTarget:self
                      action:@selector(buyButtonTapped:)
            forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = buyButton;
    }

    return cell;
}

- (void)buyButtonTapped:(id)sender {
    UIButton *buyButton = (UIButton *)sender;
    SKProduct *product = _products[buyButton.tag];

    NSLog(@"Buying %@...", product.productIdentifier);
    [[QZBQuizIAPHelper sharedInstance] buyProduct:product];
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(productPurchased:)
                                                 name:IAPHelperProductPurchasedNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
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
    [[QZBQuizIAPHelper sharedInstance] restoreCompletedTransactions];
}

@end
