//
//  QZBStoreMainVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 26/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBStoreMainVC.h"
#import "QZBQuizIAPHelper.h"

@interface QZBStoreMainVC ()

//@property (strong, nonatomic) NSArray *products;

@property(strong, nonatomic) SKProduct *twiceBooster;
@property(strong, nonatomic) SKProduct *tripleBooster;

@end

@implementation QZBStoreMainVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [QZBQuizIAPHelper sharedInstance];

    [self reload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(productPurchased:)
                                                 name:IAPHelperProductPurchasedNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}




- (IBAction)purchaseTwiceBoosterAction:(id)sender {
    
   // NSLog(@"Buying %@...", product.productIdentifier);
    [[QZBQuizIAPHelper sharedInstance] buyProduct:self.twiceBooster];
}
- (IBAction)purchaseTripleBoosterAction:(id)sender {
    
    [[QZBQuizIAPHelper sharedInstance] buyProduct:self.tripleBooster];
    
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
    }];
}

- (void)setButtonTitleForProduct:(SKProduct *)product button:(UIButton *)button {
    if ([[QZBQuizIAPHelper sharedInstance] productPurchased:product.productIdentifier]) {
        [button setTitle:@"Куплено" forState:UIControlStateNormal];
        button.enabled = NO;

    } else {
        [button setTitle:[self.priceFormatter stringFromNumber:product.price]
                forState:UIControlStateNormal];
    }
}

- (void)productPurchased:(NSNotification *)notification {
    NSString *productIdentifier = notification.object;
    
    if([self.twiceBooster.productIdentifier isEqualToString:productIdentifier]){
        [self setButtonTitleForProduct:self.twiceBooster button:self.purchseTwiceBoosterButton];
    }else if ([self.tripleBooster.productIdentifier isEqualToString:productIdentifier]){
        [self setButtonTitleForProduct:self.tripleBooster button:self.purchaseTripleBoosterButton];
    }
    
}



- (void)restoreTapped:(id)sender {
    [[QZBQuizIAPHelper sharedInstance] restoreCompletedTransactions];
}

@end
