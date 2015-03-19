//
//  QZBIAPHelper.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 25/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;
UIKIT_EXTERN NSString *const IAPHelperProductPurchaseFailed;

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface QZBIAPHelper : NSObject

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;

- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;

- (void)restoreCompletedTransactions;

-(void)setProductIdentifiersFromProducts:(NSSet *)productIdentifiers;


@end
