//
//  QZBLobby.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 28/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBLobby.h"

@interface QZBLobby ()

@property (assign, nonatomic) NSInteger lobbyID;
@property (assign, nonatomic) NSInteger topicID;
@property (assign, nonatomic) NSInteger playerID;
@property (assign, nonatomic) NSInteger queryCount;

@end

@implementation QZBLobby

- (instancetype)initWithDict:(NSDictionary *)dict;
{
    
    return [self initWithLobbyID:[dict[@"id"] integerValue]
                         topicID:[dict[@"topic_id"] integerValue]
                        playerID:[dict[@"player_id"] integerValue]
                      queryCount:[dict[@"query_count"] integerValue]];
    
   
}

-(instancetype)initWithLobbyID:(NSInteger)lobbyID
               topicID:(NSInteger)topicID
              playerID:(NSInteger)playerID
            queryCount:(NSInteger)queryCount{
    self = [super init];
    if (self) {
    
        self.lobbyID = lobbyID;
        self.topicID = topicID;
        self.playerID = topicID;
        self.queryCount = queryCount;
    }
    return self;
    
}


@end
