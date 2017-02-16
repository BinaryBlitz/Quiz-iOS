//
//  QZBUserWithCategory.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 16/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QZBUserProtocol.h"

@class QZBGameTopic;

@interface QZBUserWithTopic : NSObject

@property(strong, nonatomic, readonly) id<QZBUserProtocol> user;
@property(strong, nonatomic, readonly) QZBGameTopic *topic;
@property(strong, nonatomic) NSNumber *points;
@property(assign, nonatomic, getter = isFinished) BOOL finished;
@property(assign, nonatomic, getter=isAdmin) BOOL admin;
@property(assign, nonatomic, getter=isReady) BOOL ready;
@property(strong, nonatomic) NSNumber *userWithTopicID;

- (instancetype)initWithUser:(id<QZBUserProtocol>)user topic:(QZBGameTopic *)topic;

- (void)addReachedPoints:(NSNumber *)points;

-(void)setPoints:(NSNumber *)points;

@end
