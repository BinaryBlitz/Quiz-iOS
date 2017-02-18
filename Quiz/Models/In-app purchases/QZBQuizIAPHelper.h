#import "QZBIAPHelper.h"
#import <StoreKit/StoreKit.h>

UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;

@interface QZBQuizIAPHelper : QZBIAPHelper

+ (QZBQuizIAPHelper *)sharedInstance;


@end
