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
@property(strong, nonatomic, readonly) NSNumber *points;

- (instancetype)initWithUser:(id<QZBUserProtocol>)user topic:(QZBGameTopic *)topic;

@end
