#import <Foundation/Foundation.h>

@interface QZBLobby : NSObject

@property (assign, nonatomic, readonly) NSInteger lobbyID;
@property (assign, nonatomic, readonly) NSInteger topicID;
@property (assign, nonatomic, readonly) NSInteger playerID;
@property (assign, nonatomic, readonly) NSInteger queryCount;
@property (copy, nonatomic, readonly) NSString *fact;

- (instancetype)initWithDict:(NSDictionary *)dict;
-(instancetype)initWithLobbyID:(NSInteger)lobbyID
                       topicID:(NSInteger)topicID
                      playerID:(NSInteger)playerID
                    queryCount:(NSInteger)queryCount;

@end
