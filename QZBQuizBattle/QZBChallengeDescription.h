//
//  QZBChallengeDescription.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 18/03/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QZBUserProtocol.h"

@interface QZBChallengeDescription : NSObject<QZBUserProtocol>

@property(strong, nonatomic, readonly) NSNumber *lobbyID;
@property(copy,   nonatomic, readonly) NSString *name;
@property(strong, nonatomic, readonly) NSNumber *userID;
@property(strong, nonatomic, readonly) NSNumber *topicID;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
