//
//  QZBTopicWorker.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 25/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBTopicWorker.h"
#import "QZBGameTopic.h"
//#import "QZBServerManager.h"
#import "CoreData+MagicalRecord.h"
#import "QZBCategory.h"

@implementation QZBTopicWorker

+ (QZBGameTopic *)parseTopicFromDict:(NSDictionary *)dict {
//    id topic_id = [dict objectForKey:@"id"];
//    
//    QZBGameTopic *topic = [QZBGameTopic MR_findFirstByAttribute:@"topic_id" withValue:topic_id];
//    //(QZBGameTopic *)
//    //  [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
//    
//    if (!topic) {
//        topic = [QZBGameTopic MR_createEntity];
//        topic.name = dict[@"name"];
//        topic.topic_id = topic_id;
//    }
//    topic.points = dict[@"points"];
//    topic.visible = dict[@"visible"];
    
    QZBGameTopic *topic = [[self class] parseTopicWithoutRelationFromDict:dict];
    
    QZBCategory *category = [[self class] tryFindRelatedCategoryToTopic:topic];
    
    if (category) {
        [category addRelationToTopicObject:topic];
    }

    return topic;
    
}

+ (QZBGameTopic *)parseTopicFromDict:(NSDictionary *)dict inCategory:(QZBCategory *)category {
    
//    id topic_id = [dict objectForKey:@"id"];
//    
//    QZBGameTopic *topic = [QZBGameTopic MR_findFirstByAttribute:@"topic_id" withValue:topic_id];
//    //(QZBGameTopic *)
//    //  [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
//    
//    if (!topic) {
//        topic = [QZBGameTopic MR_createEntity];
//        topic.name = dict[@"name"];
//        topic.topic_id = topic_id;
//    }
//    topic.points = dict[@"points"];
//    topic.visible = dict[@"visible"];
    QZBGameTopic *topic = [[self class] parseTopicWithoutRelationFromDict:dict];
    
  //  QZBCategory *category = [[QZBServerManager sharedManager] tryFindRelatedCategoryToTopic:topic];
    
    if (category) {
        [category addRelationToTopicObject:topic];
    }
    
    return topic;
    
}

+(QZBGameTopic *)parseTopicWithoutRelationFromDict:(NSDictionary *)dict {
    
    id topic_id = [dict objectForKey:@"id"];
    
    QZBGameTopic *topic = [QZBGameTopic MR_findFirstByAttribute:@"topic_id" withValue:topic_id];
    //(QZBGameTopic *)
    //  [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    
    if (!topic) {
        topic = [QZBGameTopic MR_createEntity];
        topic.name = dict[@"name"];
        topic.topic_id = topic_id;
    }
    topic.points = dict[@"points"];
    topic.visible = dict[@"visible"];
    
    return topic;
    
}

+ (QZBCategory *)tryFindRelatedCategoryToTopic:(QZBGameTopic *)topic {
    QZBGameTopic *exitedTopic =
    [QZBGameTopic MR_findFirstByAttribute:@"topic_id" withValue:topic.topic_id];
    QZBCategory *category = nil;
    
    if (exitedTopic) {
        category = exitedTopic.relationToCategory;
    }
    return category;
}

@end
