#import <Foundation/Foundation.h>

@class QZBRoom;
@class QZBRoomOnlineWorker;

@interface QZBRoomWorker : NSObject

@property(strong, nonatomic) QZBRoom *room;
@property(strong, nonatomic, readonly) QZBRoomOnlineWorker *onlineWorker;

- (instancetype)initWithRoom:(QZBRoom *)room;
- (void)addRoomOnlineWorker;

- (void)closeOnlineWorker;

- (void)userWithId:(NSNumber *)userID reachedPoints:(NSNumber *)points;
-(void)userWithId:(NSNumber *)userID resultPoints:(NSNumber *)points;

-(void)sortUsers;

@end
