#import "QZBChallengeDescriptionWithResults.h"
#import "QZBAnotherUser.h"
#import "QZBUser.h"
#import "QZBCurrentUser.h"
#import "QZBGameTopic.h"
#import "MagicalRecord/MagicalRecord.h"

@interface QZBChallengeDescriptionWithResults ()

@property (assign, nonatomic) NSInteger firstResult;
@property (assign, nonatomic) NSInteger opponentResult;
@property (strong, nonatomic) QZBAnotherUser *opponentUser;
@property (strong, nonatomic) QZBUser *firstUser;
@property (assign, nonatomic) NSInteger multiplier;
@property (copy, nonatomic) NSString *sessionResult;


@end

@implementation QZBChallengeDescriptionWithResults

- (instancetype)initWithDictionary:(NSDictionary *)dict {

  self = [super initWithDictionary:dict];

  if (self) {
    NSDictionary *resultDict = dict[@"results"];
    NSDictionary *firstDict = resultDict[@"host"];
    NSDictionary *opponentDict = resultDict[@"opponent"];

    self.firstResult = [resultDict[@"host_points"] integerValue]; //[self pointsFromDict:firstDict];
    self.opponentResult = [resultDict[@"opponent_points"] integerValue]; //[self pointsFromDict:opponentDict];
    self.opponentUser = [[QZBAnotherUser alloc] initWithDictionary:opponentDict];
    self.firstUser = [QZBCurrentUser sharedInstance].user;
    self.multiplier = [firstDict[@"multiplier"] integerValue];

    self.sessionResult = [self resultOfSession];

    // NSNumber *topicID = dict[@"topic_id"];

    self.topic.points = firstDict[@"points"];

  }
  return self;

}

- (NSString *)resultOfSession {
  NSString *result = nil;

  if (self.firstResult > self.opponentResult) {
    result = @"Победа";
  } else if (self.firstResult < self.opponentResult) {
    result = @"Поражение";
  } else {
    result = @"Ничья";
  }
  return result;
}


//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//
//    }
//    return self;
//}

@end
