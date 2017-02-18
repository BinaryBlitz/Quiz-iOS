#import "QZBRoomWorker.h"
#import "QZBRoom.h"
#import "QZBRoomOnlineWorker.h"
#import "QZBUserWithTopic.h"

#import <DDLog.h>

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface QZBRoomWorker ()

//@property(strong, nonatomic) QZBRoom *room;
@property (strong, nonatomic) QZBRoomOnlineWorker *onlineWorker;

@end

@implementation QZBRoomWorker

- (instancetype)initWithRoom:(QZBRoom *)room {
  self = [super init];
  if (self) {
    self.room = room;
  }
  return self;
}

- (void)addRoomOnlineWorker {
  if (!self.onlineWorker) {
    self.onlineWorker = [[QZBRoomOnlineWorker alloc] initWithRoom:self.room];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(oneOfUsersFinishedGame:)
                                                 name:QZBOneUserFinishedGameInRoom
                                               object:nil];
    // [NSNotificationCenter defaultCenter] addObserver:self selector:<#(SEL)#> name:<#(NSString *)#> object:<#(id)#>
  }
}

- (void)closeOnlineWorker {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [self.onlineWorker closeConnection];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)userWithId:(NSNumber *)userID reachedPoints:(NSNumber *)points {
  QZBUserWithTopic *userWithTopic = [self userWithTopicWithID:userID];

  for (QZBUserWithTopic *uandt in self.room.participants) {
    if ([uandt.user.userID isEqualToNumber:userID]) {
      userWithTopic = uandt;
      break;
    }
  }

  if (userWithTopic) {
    [userWithTopic addReachedPoints:points];
  }
}

- (void)userWithId:(NSNumber *)userID resultPoints:(NSNumber *)points {
  QZBUserWithTopic *userWithTopic = [self userWithTopicWithID:userID];

  if (userWithTopic) {
    [userWithTopic setPoints:points];
    userWithTopic.finished = YES;
  }
}

- (QZBUserWithTopic *)userWithTopicWithID:(NSNumber *)userID {
  // QZBUserWithTopic *userWithTopic = nil;

  for (QZBUserWithTopic *uandt in self.room.participants) {
    if ([uandt.user.userID isEqualToNumber:userID]) {
      //userWithTopic = uandt;
      return uandt;
      //break;
    }
  }
  return nil;
}

#pragma mark - notifications

- (void)oneOfUsersFinishedGame:(NSNotification *)note {
  if (note && [note.name isEqualToString:QZBOneUserFinishedGameInRoom]) {
    NSDictionary *d = note.object;

    NSNumber *userID = d[@"player_id"];
    NSNumber *points = d[@"points"];

    [self userWithId:userID resultPoints:points];

//        NSSortDescriptor *firstSort = [[NSSortDescriptor alloc] initWithKey:@"finished" ascending:NO];
//        NSSortDescriptor *secondSort = [[NSSortDescriptor alloc] initWithKey:@"points" ascending:NO];
//        
//        [self.room.participants sortUsingDescriptors:@[firstSort,secondSort]];

    [self sortUsers];

    if ([self allFinished]) {
      //  [self closeOnlineWorker];
    }
    //    [self.tableView reloadData];
  }
}

- (void)sortUsers {
  NSSortDescriptor *firstSort = [[NSSortDescriptor alloc] initWithKey:@"finished" ascending:NO];
  NSSortDescriptor *secondSort = [[NSSortDescriptor alloc] initWithKey:@"points" ascending:NO];

  [self.room.participants sortUsingDescriptors:@[firstSort, secondSort]];
}

- (BOOL)allFinished {
  for (QZBUserWithTopic *userWithTopic in self.room.participants) {
    if (userWithTopic.finished == NO) {
      return NO;
    }
  }
  DDLogCVerbose(@"ALL FINISHED");
  return YES;
}

//-(void)nlineWorker:(QZBRoomOnlineWorker *)onlineWorker


@end
