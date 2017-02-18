#import <Foundation/Foundation.h>
#import "QZBUserProtocol.h"

@class QZBGameTopic;
@interface QZBChallengeDescription : NSObject//<QZBUserProtocol>

@property(strong, nonatomic, readonly) NSNumber *lobbyID;
@property(copy,   nonatomic, readonly) NSString *name;
@property(strong, nonatomic, readonly) NSNumber *userID;
@property(strong, nonatomic, readonly) NSNumber *topicID;
@property(strong, nonatomic, readonly) NSString *topicName;
@property(strong, nonatomic, readonly) QZBGameTopic *topic;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
