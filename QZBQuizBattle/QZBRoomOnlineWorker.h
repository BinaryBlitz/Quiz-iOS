//
//  QZBRoomOnlineWorker.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 01/07/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const QZBNeedStartRoomGame;
UIKIT_EXTERN NSString *const QZBNewParticipantJoinedRoom;
UIKIT_EXTERN NSString *const QZBOneOfUserLeftRoom;
UIKIT_EXTERN NSString *const QZBOneUserChangedStatus;
UIKIT_EXTERN NSString *const QZBOneUserFinishedGameInRoom;
@class QZBRoom;

@interface QZBRoomOnlineWorker : NSObject

- (instancetype)initWithRoom:(QZBRoom *)room;
- (void)closeConnection;

@end
