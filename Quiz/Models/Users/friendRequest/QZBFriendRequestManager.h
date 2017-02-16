//
//  QZBFriendRequestManager.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 21/05/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QZBUserProtocol.h"
UIKIT_EXTERN NSString *const QZBFriendRequestUpdated;

typedef NS_ENUM(NSInteger, QZBFriendState) {
    QZBFriendStateNotDefined,
    QZBFriendStateAlredyFriend,
    QZBFriendStateNotYetFriend,
    QZBFriendStateIncomingRequest,
    QZBFriendStateOutcomingRequest
};

@interface QZBFriendRequestManager : NSObject

@property (strong, nonatomic, readonly) NSMutableArray *incoming;

+ (instancetype)sharedInstance;
- (void)updateRequests;
#pragma mark - user state
- (QZBFriendState)friendStateForUser:(id<QZBUserProtocol>)user;

#pragma mark - actions
- (void)acceptForUser:(id<QZBUserProtocol>)user callback:(void (^)(BOOL succes))callback;
- (void)declineForUser:(id<QZBUserProtocol>)user callback:(void (^)(BOOL succes))callback;
- (void)cancelForUser:(id<QZBUserProtocol>)user callback:(void (^)(BOOL succes))callback;
- (void)addFriendUser:(id<QZBUserProtocol>)user callback:(void (^)(BOOL succes))callback;

@end
