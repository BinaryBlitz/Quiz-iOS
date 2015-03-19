//
//  QZBChallengeDescription.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 18/03/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBChallengeDescription.h"

@interface QZBChallengeDescription()

@property(strong, nonatomic) NSNumber *lobbyID;
@property(copy, nonatomic) NSString *name;
@property(strong, nonatomic) NSNumber *userID;
@property(strong, nonatomic) NSNumber *topicID;

@end

@implementation QZBChallengeDescription

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.lobbyID = dict[@"id"];
        self.name = dict[@"name"];
        self.userID = dict[@"player_id"];
        self.topicID = dict[@"topic_id"];
    }
    return self;
}

@end
