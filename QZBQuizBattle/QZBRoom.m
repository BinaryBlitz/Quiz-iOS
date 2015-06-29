//
//  QZBRoom.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 16/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRoom.h"
#import "QZBAnotherUser.h"
#import "QZBUserWithTopic.h"
#import "QZBGameTopic.h"
#import "CoreData+MagicalRecord.h"
#import "QZBServerManager.h"
#import "QZBTopicWorker.h"

@interface QZBRoom ()

@property (strong, nonatomic) NSNumber *roomID;
//@property(strong, nonatomic) QZBAnotherUser *owner;
@property (strong, nonatomic) QZBUserWithTopic *owner;
@property (strong, nonatomic) NSDate *creationDate;
@property (strong, nonatomic) NSMutableArray *participants;  // QZBUserWithTopic

@end

@implementation QZBRoom

- (instancetype)initWithDictionary:(NSDictionary *)d {
    self = [super init];
    if (self) {
        self.roomID = d[@"id"];
     //   NSDictionary *userDict = d[@"owner"];
        //QZBAnotherUser *user = [[QZBAnotherUser alloc] initWithDictionary:userDict];
       // QZBGameTopic *topic = [QZBGameTopic MR_findFirst];
       // self.owner = [self parseUserWithTopicFromDict:userDict]; //[[QZBUserWithTopic alloc] initWithUser:user topic:topic];
        self.participants = [NSMutableArray array];

        NSDateFormatter *df = [[NSDateFormatter alloc] init];

        df.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
        df.locale = [NSLocale systemLocale];

        self.creationDate = [df dateFromString:d[@"created_at"]];

        self.participants = [self parseParticipants:d[@"participations"]];

    //    [self.participants insertObject:self.owner atIndex:0];
    }
    return self;
}

- (NSMutableArray *)parseParticipants:(NSArray *)participants {
    NSMutableArray *tmpArr = [NSMutableArray array];
    
    for (NSDictionary *d in participants) {
        
       
        QZBUserWithTopic *userWithTopic = [self parseUserWithTopicFromDict:d];

        [tmpArr addObject:userWithTopic];
    }

    return tmpArr;
}

-(QZBUserWithTopic *)parseUserWithTopicFromDict:(NSDictionary *)d{
    NSDictionary *playerDict = d[@"player"];
    QZBAnotherUser *user = [[QZBAnotherUser alloc] initWithDictionary:playerDict];
    
    BOOL isAdmin = [playerDict[@"is_admin"] boolValue];
    
    QZBGameTopic *topic = [QZBTopicWorker parseTopicFromDict:d[@"topic"]]; //[QZBGameTopic MR_findFirst];
    QZBUserWithTopic *userWithTopic = [[QZBUserWithTopic alloc] initWithUser:user topic:topic];
    
    userWithTopic.admin = isAdmin;

    return userWithTopic;
    
}

- (NSString *)descriptionForUserWithTopic:(QZBUserWithTopic *)userWithTopic {
    NSMutableString *res = [NSMutableString string];

    [res appendString:userWithTopic.user.name];
    [res appendString:@"   "];
    [res appendString:userWithTopic.topic.name];
    return [NSString stringWithString:res];
}

- (NSString *)descriptionForAllUsers {
    NSMutableString *res = [NSMutableString string];

    // NSString *ownerString = [self descriptionForUserWithTopic:self.owner];

    // [res appendFormat:@"%@\n",ownerString];

    NSInteger count = self.participants.count;

    [res appendFormat:@"%ld игроков\n темы:", (long)count];

    for (QZBUserWithTopic *userWithTopic in self.participants) {
        [res appendFormat:@"%@, ", userWithTopic.topic.name];
    }
    return res;
}

- (NSString *)participantsDescription {
    NSInteger count = self.participants.count;
    return [NSString stringWithFormat:@"Количество игроков: %ld", (long)count];
}

- (NSString *)topicsDescription {
    NSMutableString *res = [NSMutableString string];

    [res appendString:@"Темы: "];

    for (QZBUserWithTopic *userWithTopic in self.participants) {
        NSString *topicName = [userWithTopic.topic.name
            stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        [res appendString:topicName];
        [res appendString:@", "];
    }
    return [NSString stringWithString:res];
}

#pragma mark - users
- (void)addUser:(QZBUserWithTopic *)userWithTopic {
    if (![self isContainUser:userWithTopic.user]) {
        [self.participants addObject:userWithTopic];
    }
}

- (void)removeUser:(QZBUserWithTopic *)userWithTopic {
    if ([self.participants containsObject:userWithTopic]) {
        [self.participants removeObject:userWithTopic];
    }
}

- (BOOL)isContainUser:(id<QZBUserProtocol>)user {
    for (QZBUserWithTopic *userWithTopic in self.participants) {
        if ([userWithTopic.user.userID isEqualToNumber:user.userID]) {
            return YES;
        }
    }
    return NO;
}


#pragma mark - results

-(NSArray *)resultParticipants{
    
    NSSortDescriptor *finishedSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"isFinished" ascending:NO];
    
    NSSortDescriptor *pointsDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"points" ascending:NO];
    
    //TEST
    
    return [self.participants
            sortedArrayUsingDescriptors:@[finishedSortDescriptor,pointsDescriptor]];
    
}




@end
