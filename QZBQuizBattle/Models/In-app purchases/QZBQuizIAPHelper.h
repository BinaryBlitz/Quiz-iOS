//
//  QZBQuizIAPHelper.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 25/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBIAPHelper.h"
#import <StoreKit/StoreKit.h>
UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;


@interface QZBQuizIAPHelper : QZBIAPHelper

+ (QZBQuizIAPHelper *)sharedInstance;


@end
