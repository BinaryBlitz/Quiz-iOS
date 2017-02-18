#import "QZBChallengeDescription.h"
#import "QZBGameTopic.h"
#import "AppDelegate.h"
#import "QZBTopicWorker.h"

@interface QZBChallengeDescription ()

@property (strong, nonatomic) NSNumber *lobbyID;
@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *userID;
@property (strong, nonatomic) NSNumber *topicID;
@property (strong, nonatomic) NSString *topicName;
@property (strong, nonatomic) QZBGameTopic *topic;

@end

@implementation QZBChallengeDescription

- (instancetype)initWithDictionary:(NSDictionary *)dict {
  self = [super init];
  if (self) {
    self.lobbyID = dict[@"id"];

    if (![dict[@"username"] isEqual:[NSNull null]] && dict[@"username"]) {
      self.name = dict[@"username"];
    } else {
      self.name = dict[@"name"];
    }

    NSDictionary *topicDict = dict[@"topic"];

    self.userID = dict[@"player_id"];

    self.topic = [QZBTopicWorker parseTopicFromDict:topicDict];//TEST



    // self.topic = topic;

    self.topicName = self.topic.name;
    self.topicID = dict[@"topic_id"];
  }
  return self;
}

@end
