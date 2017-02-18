#import <Foundation/Foundation.h>

@class QZBGameTopic;
@class QZBCategory;

@interface QZBTopicWorker : NSObject

+ (QZBGameTopic *)parseTopicFromDict:(NSDictionary *)dict;

+ (QZBCategory *)tryFindRelatedCategoryToTopic:(QZBGameTopic *)topic;

+ (QZBGameTopic *)parseTopicFromDict:(NSDictionary *)dict inCategory:(QZBCategory *)category;

@end
