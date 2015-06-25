//
//  QZBUserWithCategory.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 16/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBUserWithTopic.h"
#import "QZBAnotherUser.h"
#import "QZBGameTopic.h"

@interface QZBUserWithTopic()

@property(strong, nonatomic) id<QZBUserProtocol> user;
@property(strong, nonatomic) QZBGameTopic *topic;
@property(strong, nonatomic) NSNumber *points;

@end

@implementation QZBUserWithTopic

- (instancetype)initWithUser:(id<QZBUserProtocol>)user topic:(QZBGameTopic *)topic
{
    self = [super init];
    if (self) {
        self.user = user;
        self.topic = topic;
    }
    return self;
}

@end
