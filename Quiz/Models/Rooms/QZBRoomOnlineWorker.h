//#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const QZBNeedStartRoomGame;
UIKIT_EXTERN NSString *const QZBNewParticipantJoinedRoom;
UIKIT_EXTERN NSString *const QZBOneOfUserLeftRoom;
UIKIT_EXTERN NSString *const QZBOneUserChangedStatus;
UIKIT_EXTERN NSString *const QZBOneUserFinishedGameInRoom;
UIKIT_EXTERN NSString *const QZBRoomMessageRecieved;
@class QZBRoom;

@interface QZBRoomOnlineWorker : NSObject

- (instancetype)initWithRoom:(QZBRoom *)room;

- (void)closeConnection;

@end
