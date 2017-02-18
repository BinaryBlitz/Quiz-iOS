#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;
UIKIT_EXTERN NSString *const IAPHelperProductPurchaseFailed;
UIKIT_EXTERN NSString *const IAPHelperProductRestoreFinished;

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray *products);

@interface QZBIAPHelper : NSObject

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;

- (int)daysRemainingOnSubscriptionFromIdentifier:(NSString *)identifier;

- (void)buyProduct:(SKProduct *)product;

- (BOOL)productPurchased:(NSString *)productIdentifier;

- (void)restoreCompletedTransactions;

- (void)setProductIdentifiersFromProducts:(NSSet *)productIdentifiers;


@end
