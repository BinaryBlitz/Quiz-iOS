//
//  QZBLobby.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 28/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBLobby.h"

@interface QZBLobby()

@property (assign, nonatomic) NSInteger lobbyID;
@property (assign, nonatomic) NSInteger topicID;
@property (assign, nonatomic) NSInteger playerID;
@property (assign, nonatomic) NSInteger queryCount;

@end

@implementation QZBLobby

- (instancetype)initWithDict:(NSDictionary *)dict;
{
  self = [super init];
  if (self) {
    
    self.lobbyID = [dict[@"id"] integerValue];
    self.topicID = [dict[@"topic_id"] integerValue];
    self.playerID = [dict[@"player_id"] integerValue];
    self.queryCount = [dict[@"query_count"] integerValue];
                     
    
  }
  return self;
}



@end
