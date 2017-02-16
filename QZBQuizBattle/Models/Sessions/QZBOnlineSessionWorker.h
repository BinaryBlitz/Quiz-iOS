//
//  QZBOnlineSessionWorker.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 29/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const QZBPusherConnectionProblrms;
UIKIT_EXTERN NSString *const QZBPusherChallengeDeclined;

@interface QZBOnlineSessionWorker : NSObject

- (void)closeConnection;

@end
