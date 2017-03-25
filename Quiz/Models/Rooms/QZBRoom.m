#import "QZBRoom.h"
#import "QZBAnotherUser.h"
#import "QZBUserWithTopic.h"
#import "QZBGameTopic.h"
#import "MagicalRecord/MagicalRecord.h"
#import "QZBTopicWorker.h"

@interface QZBRoom ()

@property (strong, nonatomic) NSNumber *roomID;
@property (strong, nonatomic) QZBUserWithTopic *owner;
@property (strong, nonatomic) NSDate *creationDate;
@property (strong, nonatomic) NSMutableArray *participants;
@property (assign, nonatomic) BOOL isFriendOnly;

@property (strong, nonatomic) NSNumber *maxUserCount;

@end

@implementation QZBRoom

- (instancetype)initWithDictionary:(NSDictionary *)d {
  self = [super init];
  if (self) {
    self.roomID = d[@"id"];
    self.participants = [NSMutableArray array];

    NSDateFormatter *df = [[NSDateFormatter alloc] init];

    df.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    df.locale = [NSLocale systemLocale];

    if (d[@"created_at"]) {
      self.creationDate = [df dateFromString:d[@"created_at"]];
    }

    if (d[@"participations"]) {
      self.participants = [self parseParticipants:d[@"participations"]];
    }

    for (QZBUserWithTopic *userWithTopic in self.participants) {

      if (userWithTopic.isAdmin) {
        self.owner = userWithTopic;
        break;
      }
    }

    id usersCount = d[@"size"];

    if (usersCount && ![usersCount isEqual:[NSNull null]]) {
      self.maxUserCount = (NSNumber *) usersCount;
    } else {
      self.maxUserCount = @(5);
    }
    if (d[@"friends_only"]) {
      self.isFriendOnly = [d[@"friends_only"] boolValue];
    }
  }
  return self;
}

- (NSMutableArray *)parseParticipants:(NSArray *)participants {
  NSMutableArray *tmpArr = [NSMutableArray array];

  for (NSDictionary *d in participants) {

    QZBUserWithTopic *userWithTopic = [self parseUserWithTopicFromDict:d];

    [tmpArr addObject:userWithTopic];
  }

  NSSortDescriptor *firstSortDescr = [NSSortDescriptor sortDescriptorWithKey:@"userWithTopicID"
                                                                   ascending:YES];

  [tmpArr sortUsingDescriptors:@[firstSortDescr]];
  return tmpArr;
}

- (QZBUserWithTopic *)parseUserWithTopicFromDict:(NSDictionary *)d {
  NSDictionary *playerDict = d[@"player"];
  QZBAnotherUser *user = [[QZBAnotherUser alloc] initWithDictionary:playerDict];

  BOOL isAdmin = [playerDict[@"is_admin"] boolValue];
  BOOL isFinished = [d[@"finished"] boolValue];
  BOOL isReady = [d[@"ready"] boolValue];

  if (playerDict[@"is_friend"] && ![playerDict[@"is_friend"] isEqual:[NSNull null]]) {

    user.isFriend = [playerDict[@"is_friend"] boolValue];
  }

  NSNumber *userWithTopicID = d[@"id"];

  QZBGameTopic *topic = [QZBTopicWorker parseTopicFromDict:d[@"topic"]];
  QZBUserWithTopic *userWithTopic = [[QZBUserWithTopic alloc] initWithUser:user topic:topic];

  userWithTopic.admin = isAdmin;
  userWithTopic.finished = isFinished;
  userWithTopic.ready = isReady;
  userWithTopic.userWithTopicID = userWithTopicID;

  return userWithTopic;
}

- (NSAttributedString *)descriptionForUserWithTopic:(QZBUserWithTopic *)userWithTopic {

  NSString *name = userWithTopic.user.name;

  NSMutableAttributedString *attributedName = [[NSMutableAttributedString alloc]
                                               initWithString:name];
  NSRange nameRange = NSMakeRange(0, name.length);

  UIFont *museoFontBig = [UIFont boldSystemFontOfSize:20];

  [attributedName addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:nameRange];
  [attributedName addAttribute:NSFontAttributeName value:museoFontBig range:nameRange];

  NSString *topicName = [userWithTopic.topic.name
                         stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
  NSRange topicNameRange = NSMakeRange(0, topicName.length);
  UIFont *museoFontSmall = [UIFont systemFontOfSize:12];

  NSMutableAttributedString *attributedTopicName = [[NSMutableAttributedString alloc] initWithString:topicName];

  [attributedTopicName addAttribute:NSForegroundColorAttributeName value:[UIColor lightTextColor] range:topicNameRange];
  [attributedTopicName addAttribute:NSFontAttributeName value:museoFontSmall range:topicNameRange];

  NSAttributedString *nextLineString = [[NSAttributedString alloc] initWithString:@"\n"];

  [attributedName appendAttributedString:nextLineString];
  [attributedName appendAttributedString:attributedTopicName];

  return [[NSAttributedString alloc] initWithAttributedString:attributedName];
}

- (NSString *)descriptionForAllUsers {
  NSMutableString *res = [NSMutableString string];

  NSInteger count = self.participants.count;

  [res appendFormat:@"%ld игроков\n темы:", (long) count];

  for (QZBUserWithTopic *userWithTopic in self.participants) {
    [res appendFormat:@"%@, ", userWithTopic.topic.name];
  }
  return res;
}

- (NSString *)participantsDescription {
  NSInteger count = self.participants.count;
  NSString *participantsDescription =
  [NSString stringWithFormat:@"Количество игроков: %ld", (long) count];
  if (self.maxUserCount) {
    NSString *appendString = [NSString stringWithFormat:@" из %@", self.maxUserCount];
    participantsDescription = [participantsDescription stringByAppendingString:appendString];
  }
  return participantsDescription;
}

- (NSString *)topicsDescription {
  NSMutableString *res = [NSMutableString string];

  [res appendString:@"Темы: "];

  for (int i = 0; i < self.participants.count; i++) {
    QZBUserWithTopic *userWithTopic = self.participants[i];
    NSString *topicName = [userWithTopic.topic.name
                           stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    [res appendString:topicName];

    if (i < self.participants.count - 1)
      [res appendString:@", "];
  }

  return [NSString stringWithString:res];
}

#pragma mark - users

- (void)addUser:(QZBUserWithTopic *)userWithTopic {
  if (![self isContainUser:userWithTopic.user]) {
    [self.participants addObject:userWithTopic];
  }
}

- (void)removeUser:(QZBUserWithTopic *)userWithTopic {
  if ([self.participants containsObject:userWithTopic]) {
    [self.participants removeObject:userWithTopic];
  }
}

- (BOOL)isContainUser:(id <QZBUserProtocol>)user {
  for (QZBUserWithTopic *userWithTopic in self.participants) {
    if ([userWithTopic.user.userID isEqualToNumber:user.userID]) {
      return YES;
    }
  }
  return NO;
}

- (QZBUserWithTopic *)findUserWithID:(NSNumber *)userID {
  for (QZBUserWithTopic *userWithTopic in self.participants) {
    if ([userWithTopic.user.userID isEqualToNumber:userID]) {
      return userWithTopic;
    }
  }
  return nil;
}

#pragma mark - results

- (NSArray *)resultParticipants {

  NSSortDescriptor *finishedSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"isFinished" ascending:NO];
  NSSortDescriptor *pointsDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"points" ascending:NO];
  
  return [self.participants
          sortedArrayUsingDescriptors:@[finishedSortDescriptor, pointsDescriptor]];
}


@end
