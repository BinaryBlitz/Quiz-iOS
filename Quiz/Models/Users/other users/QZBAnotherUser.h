#import <Foundation/Foundation.h>
#import "QZBUserProtocol.h"

@class QZBUserStatistic;

@interface QZBAnotherUser : NSObject<QZBUserProtocol>

@property(strong, nonatomic) NSNumber *userID;
@property(copy, nonatomic) NSString *name;
@property(assign, nonatomic) BOOL isFriend;
@property(strong, nonatomic) NSURL *imageURL;
@property(strong, nonatomic) NSURL *imageURLBig;
@property(strong, nonatomic) NSArray *faveTopics;//QZBGameTopic
@property(strong, nonatomic) NSArray *achievements;//QZBAchievement
@property(assign, nonatomic) BOOL isViewed;
@property(assign, nonatomic) BOOL isOnline;

@property(strong, nonatomic) QZBUserStatistic *userStatistics;

- (instancetype)initWithDictionary:(NSDictionary *)dict;


@end
