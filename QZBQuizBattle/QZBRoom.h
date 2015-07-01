//
//  QZBRoom.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 16/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QZBUserProtocol.h"

@class QZBUserWithTopic;
@class QZBAnotherUser;

@interface QZBRoom : NSObject

@property(strong, nonatomic, readonly) NSNumber *roomID;
@property(strong, nonatomic, readonly) QZBUserWithTopic *owner;
@property(strong, nonatomic, readonly) NSMutableArray *participants;
@property(strong, nonatomic, readonly) NSDate *creationDate;

@property(strong, nonatomic, readonly) NSNumber *maxUserCount;;

- (instancetype)initWithDictionary:(NSDictionary *)d;

- (BOOL)isContainUser:(id<QZBUserProtocol>)user;

- (void)addUser:(QZBUserWithTopic *)userWithTopic;

- (void)removeUser:(QZBUserWithTopic *)userWithTopic;

- (NSAttributedString *)descriptionForUserWithTopic:(QZBUserWithTopic *)userWithTopic;

//- (NSString *)descriptionForUserWithTopic:(QZBUserWithTopic *)userWithTopic;

//- (NSString *)descriptionForAllUsers;

- (NSString *)participantsDescription;
- (NSString *)topicsDescription;



@end
