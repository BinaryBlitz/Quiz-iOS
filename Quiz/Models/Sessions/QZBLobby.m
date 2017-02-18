#import "QZBLobby.h"

@interface QZBLobby ()

@property (assign, nonatomic) NSInteger lobbyID;
@property (assign, nonatomic) NSInteger topicID;
@property (assign, nonatomic) NSInteger playerID;
@property (assign, nonatomic) NSInteger queryCount;
@property (copy, nonatomic) NSString *fact;

@end

@implementation QZBLobby

- (instancetype)initWithDict:(NSDictionary *)dict; {

  return [self initWithLobbyID:[dict[@"id"] integerValue]
                       topicID:[dict[@"topic_id"] integerValue]
                      playerID:[dict[@"player_id"] integerValue]
                    queryCount:[dict[@"query_count"] integerValue]
                          fact:dict[@"fact"]];

//    return [self initWithLobbyID:[dict[@"id"] integerValue]
//                         topicID:[dict[@"topic_id"] integerValue]
//                        playerID:[dict[@"player_id"] integerValue]
//                      queryCount:[dict[@"query_count"] integerValue]];


}

- (instancetype)initWithLobbyID:(NSInteger)lobbyID
                        topicID:(NSInteger)topicID
                       playerID:(NSInteger)playerID
                     queryCount:(NSInteger)queryCount {
  self = [super init];
  if (self) {

    self.lobbyID = lobbyID;
    self.topicID = topicID;
    self.playerID = topicID;
    self.queryCount = queryCount;
  }
  return self;

}

- (instancetype)initWithLobbyID:(NSInteger)lobbyID
                        topicID:(NSInteger)topicID
                       playerID:(NSInteger)playerID
                     queryCount:(NSInteger)queryCount fact:(NSString *)fact {
  self = [super init];
  if (self) {

    self.lobbyID = lobbyID;
    self.topicID = topicID;
    self.playerID = topicID;
    self.queryCount = queryCount;
    self.fact = fact;
  }
  return self;

}


@end
