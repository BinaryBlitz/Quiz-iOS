#import "QZBRoomSessionResults.h"

//#import "QZBRoom.h"
//#import "QZBRoomWorker.h"
//#import "QZBUserWithTopic.h"
//
@interface QZBRoomSessionResults ()

@property (strong, nonatomic) NSArray *users;

@property (strong, nonatomic) NSDictionary *resDict;
@end

@implementation QZBRoomSessionResults

- (instancetype)initWithDictionary:(NSDictionary *)dict {
  self = [super init];
  if (self) {

    NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
    NSArray *roomQuests = dict[@"room_questions"];

    for (NSDictionary *questDict in roomQuests) {
      NSDictionary *tmpDict = questDict[@"room_question"];

      NSArray *questAnswers = tmpDict[@"room_answers"];

      for (NSDictionary *userAnswerDict in questAnswers) {
        BOOL isRight = [userAnswerDict[@"is_correct"] boolValue];
        NSNumber *userID = userAnswerDict[@"player_id"];
        NSInteger time = [userAnswerDict[@"time"] integerValue];

        NSInteger points = [self pointsForTime:time correct:isRight];

        if (resultDict[userID]) {
          NSInteger oldPoints = [resultDict[userID] integerValue];

          resultDict[userID] = @(oldPoints + points);
        } else {
          resultDict[userID] = @(points);
        }
      }
    }

    self.resDict = [NSDictionary dictionaryWithDictionary:resultDict];
    NSLog(@"res dict %@", self.resDict);
  }
  return self;
}

- (NSNumber *)pointsForUserWithID:(NSNumber *)userID {

  return self.resDict[userID];
}

- (NSInteger)pointsForTime:(NSInteger)time correct:(BOOL)correct {

  if (correct) {
    return 20 - time;
  } else {
    return 0;
  }
}

@end
