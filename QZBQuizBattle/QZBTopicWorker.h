//
//  QZBTopicWorker.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 25/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QZBGameTopic;
@class QZBCategory;

@interface QZBTopicWorker : NSObject

+ (QZBGameTopic *)parseTopicFromDict:(NSDictionary *)dict;

+ (QZBCategory *)tryFindRelatedCategoryToTopic:(QZBGameTopic *)topic;

+ (QZBGameTopic *)parseTopicFromDict:(NSDictionary *)dict inCategory:(QZBCategory *)category;

@end
