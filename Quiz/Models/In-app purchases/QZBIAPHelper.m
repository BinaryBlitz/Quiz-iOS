#import "QZBIAPHelper.h"
#import "QZBServerManager.h"
#import "QZBCurrentUser.h"
#import <CommonCrypto/CommonCrypto.h>
#import "QZBProduct.h"
#import <DDLog.h>

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";

NSString *const IAPHelperProductPurchaseFailed = @"IAPHelperProductPurchaseFailed";

NSString *const IAPHelperProductRestoreFinished = @"IAPHelperProductRestoreFinished";

@interface QZBIAPHelper () <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (strong, nonatomic) SKProductsRequest *productsRequest;
@property (copy, nonatomic) RequestProductsCompletionHandler completionHandler;
@property (strong, nonatomic) NSSet *productIdentifiers;
@property (strong, nonatomic) NSMutableSet *purchasedProductIdentifiers;
@property (strong, nonatomic) NSMutableSet *products;  // QZBProduct

@end

@implementation QZBIAPHelper

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
  if ((self = [super init])) {
    self.purchasedProductIdentifiers = [NSMutableSet set];
  }
  return self;
}

- (void)setProductIdentifiersFromProducts:(NSSet *)productIdentifiers {
  NSMutableSet *tmpProducts = [NSMutableSet set];

  self.purchasedProductIdentifiers = [NSMutableSet set];
  self.products = [productIdentifiers mutableCopy];

  for (QZBProduct *product in productIdentifiers) {
    DDLogInfo(@"identifier %@", product.identifier);

    [tmpProducts addObject:product.identifier];
    //[self.productIdentifiers addObject:product.identifier];
    if (product.isPurchased) {
      [_purchasedProductIdentifiers addObject:product.identifier];
    }
  }
  _productIdentifiers = [NSSet setWithSet:tmpProducts];

  [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler {
  // 1
  _completionHandler = [completionHandler copy];

  // 2
  _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
  _productsRequest.delegate = self;
  [_productsRequest start];
}

- (BOOL)productPurchased:(NSString *)productIdentifier {
  return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)buyProduct:(SKProduct *)product {
  DDLogInfo(@"Buying %@...", product.productIdentifier);

  SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
  NSString *identifier = [QZBCurrentUser sharedInstance].user.name;
  payment.applicationUsername = [self hashedValueForAccountName:identifier];

  [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (int)daysRemainingOnSubscriptionFromIdentifier:(NSString *)identifier {

  for (QZBProduct *product in self.products) {
    if ([product.identifier isEqualToString:identifier]) {
      return product.dayCount;
    }
  }

  return -1;
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request
     didReceiveResponse:(SKProductsResponse *)response {
  DDLogInfo(@"Loaded list of products...");
  _productsRequest = nil;

  NSArray *skProducts = response.products;
  DDLogInfo(@"sk %@", response.products);
  for (SKProduct *skProduct in skProducts) {
    DDLogInfo(@"Found product: %@ %@ %0.2f", skProduct.productIdentifier, skProduct.localizedTitle,
        skProduct.price.floatValue);
  }

  _completionHandler(YES, skProducts);
  _completionHandler = nil;
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {

  DDLogWarn(@"Failed to load list of products. %@", error);
  _productsRequest = nil;

  _completionHandler(NO, nil);
  _completionHandler = nil;
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
  for (SKPaymentTransaction *transaction in transactions) {
    switch (transaction.transactionState) {
      case SKPaymentTransactionStatePurchased:
        [self completeTransaction:transaction];
        break;
      case SKPaymentTransactionStateFailed:
        [self failedTransaction:transaction];
        break;
      case SKPaymentTransactionStateRestored:
        [self restoreTransaction:transaction];
      default:
        break;
    }
  };
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
  DDLogInfo(@"completeTransaction...");

  [self provideContentForProductIdentifier:transaction.payment.productIdentifier];

  [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
  DDLogInfo(@"restoreTransaction...");

  [self provideContentForProductIdentifier:transaction.originalTransaction.payment
      .productIdentifier];
  [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
  DDLogWarn(@"failedTransaction...");
  if (transaction.error.code != SKErrorPaymentCancelled) {
    DDLogWarn(@"Transaction error: %@", transaction.error.localizedDescription);
  }

  [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchaseFailed
                                                      object:transaction];

  [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)provideContentForProductIdentifier:(NSString *)productIdentifier {
  DDLogInfo(@"%@", productIdentifier);
  //
  [[QZBServerManager sharedManager] POSTInAppPurchaseIdentifier:productIdentifier
                                                      onSuccess:^{

                                                        [_purchasedProductIdentifiers addObject:productIdentifier];

                                                        [[NSNotificationCenter defaultCenter]
                                                            postNotificationName:IAPHelperProductPurchasedNotification
                                                                          object:productIdentifier
                                                                        userInfo:nil];
                                                      }
                                                      onFailure:^(NSError *error, NSInteger statusCode) {

                                                        [[NSNotificationCenter defaultCenter]
                                                            postNotificationName:IAPHelperProductPurchaseFailed
                                                                          object:productIdentifier];
                                                      }];
}

- (void)restoreCompletedTransactions {
  NSString *identifier = [QZBCurrentUser sharedInstance].user.name;

  [[SKPaymentQueue defaultQueue] restoreCompletedTransactionsWithApplicationUsername:
      [self hashedValueForAccountName:identifier]];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {

  DDLogInfo(@"restored");
  [[NSNotificationCenter defaultCenter]
      postNotificationName:IAPHelperProductRestoreFinished object:nil];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
  DDLogInfo(@"restore fail %@", error);

  [[NSNotificationCenter defaultCenter]
      postNotificationName:IAPHelperProductRestoreFinished object:nil];
}

#pragma mark - crypto

- (NSString *)hashedValueForAccountName:(NSString *)userAccountName {
  const int HASH_SIZE = 32;
  unsigned char hashedChars[HASH_SIZE];
  const char *accountName = [userAccountName UTF8String];
  size_t accountNameLen = strlen(accountName);

  // Confirm that the length of the user name is small enough
  // to be recast when calling the hash function.
  if (accountNameLen > UINT32_MAX) {
    DDLogInfo(@"Account name too long to hash: %@", userAccountName);
    return nil;
  }
  CC_SHA256(accountName, (CC_LONG) accountNameLen, hashedChars);

  // Convert the array of bytes into a string showing its hex representation.
  NSMutableString *userAccountHash = [[NSMutableString alloc] init];
  for (int i = 0; i < HASH_SIZE; i++) {
    // Add a dash every four bytes, for readability.
    if (i != 0 && i % 4 == 0) {
      [userAccountHash appendString:@"-"];
    }
    [userAccountHash appendFormat:@"%02x", hashedChars[i]];
  }

  return userAccountHash;
}

@end
