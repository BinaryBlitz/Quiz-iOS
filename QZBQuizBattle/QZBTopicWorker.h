//
//  QZBTopicWorker.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 25/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QZBGameTopic;

@interface QZBTopicWorker : NSObject

+ (QZBGameTopic *)parseTopicFromDict:(NSDictionary *)dict;

@end
