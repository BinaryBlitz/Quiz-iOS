//
//  QZBMainTBC.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 30/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>

NSInteger const topicsBar = 0;
NSInteger const userBar = 1;
NSInteger const mainBar = 2;
NSInteger const rateBar = 3;
NSInteger const storeBar = 4;

UIKIT_EXTERN NSString *const QZBDoNotNeedShowMessagerNotifications;

UIKIT_EXTERN NSString *const QZBNeedShowMessagerNotifications;

@interface QZBMainTBC : UITabBarController

@end
