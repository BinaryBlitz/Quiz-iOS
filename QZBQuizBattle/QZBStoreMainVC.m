//
//  QZBStoreMainVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 26/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBStoreMainVC.h"
#import "QZBQuizIAPHelper.h"
#import "QZBServerManager.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface QZBStoreMainVC ()

//@property (strong, nonatomic) NSArray *products;

@property (strong, nonatomic) SKProduct *twiceBooster;
@property (strong, nonatomic) SKProduct *tripleBooster;
@property (strong, nonatomic) NSNumberFormatter *priceFormatter;

@end

@implementation QZBStoreMainVC

- (void)viewDidLoad {
    [super viewDidLoad];

    _priceFormatter = [[NSNumberFormatter alloc] init];

    [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];

    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Востановить"
                                         style:UIBarButtonItemStyleBordered
                                        target:self
                                        action:@selector(restoreTapped:)];
    
    [[QZBServerManager sharedManager] GETInAppPurchasesOnSuccess:^(NSArray *purchases) {
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
    }];

    [QZBQuizIAPHelper sharedInstance];

    self.purchaseTripleBoosterButton.hidden = YES;
    self.purchseTwiceBoosterButton.hidden = YES;

    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];

    [self reload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(productPurchased:)
                                                 name:IAPHelperProductPurchasedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transactionFailed:) name:IAPHelperProductPurchaseFailed object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)purchaseTwiceBoosterAction:(id)sender {
    // NSLog(@"Buying %@...", product.productIdentifier);
    [[QZBQuizIAPHelper sharedInstance] buyProduct:self.twiceBooster];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
}
- (IBAction)purchaseTripleBoosterAction:(id)sender {
    [[QZBQuizIAPHelper sharedInstance] buyProduct:self.tripleBooster];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
}

- (void)reload {
    [[QZBQuizIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success,
                                                                              NSArray *products) {
        if (success) {
            //_products = products;

            for (SKProduct *product in products) {
                if ([product.productIdentifier
                        isEqualToString:@"drumih.QZBQuizBattle.twiceBooster"]) {
                    self.twiceBooster = product;
                    [self setButtonTitleForProduct:product button:self.purchseTwiceBoosterButton];
                } else if ([product.productIdentifier
                               isEqualToString:@"drumih.QZBQuizBattle.tripleBooster"]) {
                    [self setButtonTitleForProduct:product button:self.purchaseTripleBoosterButton];
                    self.tripleBooster = product;
                }
            }
        }
        [SVProgressHUD dismiss];
    }];
}

- (void)setButtonTitleForProduct:(SKProduct *)product button:(UIButton *)button {
    if ([[QZBQuizIAPHelper sharedInstance] productPurchased:product.productIdentifier]) {
        [button setTitle:@"Куплено" forState:UIControlStateNormal];
        button.enabled = NO;

    } else {
        [self.priceFormatter setLocale:product.priceLocale];
        [button setTitle:[self.priceFormatter stringFromNumber:product.price]
                forState:UIControlStateNormal];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       button.hidden = NO;
                       //[SVProgressHUD dismiss];
                   });
}

-(void)transactionFailed:(NSNotification *)notification{
    [SVProgressHUD dismiss];
}

- (void)productPurchased:(NSNotification *)notification {
    NSString *productIdentifier = notification.object;

    if ([self.twiceBooster.productIdentifier isEqualToString:productIdentifier]) {
        [self setButtonTitleForProduct:self.twiceBooster button:self.purchseTwiceBoosterButton];
    } else if ([self.tripleBooster.productIdentifier isEqualToString:productIdentifier]) {
        [self setButtonTitleForProduct:self.tripleBooster button:self.purchaseTripleBoosterButton];
    }
    [SVProgressHUD dismiss];
}

- (void)restoreTapped:(id)sender {
    [[QZBQuizIAPHelper sharedInstance] restoreCompletedTransactions];
}


@end
