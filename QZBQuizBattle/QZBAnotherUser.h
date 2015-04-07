//
//  QZBAnotherUser.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 12/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QZBUserProtocol.h"

@class QZBUserStatistic;

@interface QZBAnotherUser : NSObject<QZBUserProtocol>

@property(strong, nonatomic) NSNumber *userID;
@property(copy, nonatomic) NSString *name;
@property(assign, nonatomic) BOOL isFriend;
@property(strong, nonatomic) NSURL *imageURL;
@property(strong, nonatomic) NSArray *faveTopics;//QZBGameTopic
@property(strong, nonatomic) NSArray *achievements;//QZBAchievement

@property(strong, nonatomic) QZBUserStatistic *userStatistics;

- (instancetype)initWithDictionary:(NSDictionary *)dict;


@end
