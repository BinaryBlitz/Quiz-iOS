

#import "QZBOnlineSessionWorker.h"
#import <Pusher/Pusher.h>
#import "QZBSessionManager.h"
#import "QZBCurrentUser.h"
#import "Reachability.h"
#import <DDLog.h>

static const int ddLogLevel = LOG_LEVEL_VERBOSE;
NSString *const QZBPusherConnectionProblrms = @"QZBPusherConnectionProblrms";
NSString *const QZBPusherChallengeDeclined = @"QZBChallengeDeclined";

@interface QZBOnlineSessionWorker () <PTPusherDelegate>

@property (strong, nonatomic) PTPusher *client;
@property (strong, nonatomic) PTPusherChannel *channel;
@property (assign, nonatomic) BOOL yetStarted;

@end

@implementation QZBOnlineSessionWorker

- (instancetype)init {
  self = [super init];
  if (self) {

    NSNumber *playerID = [QZBCurrentUser sharedInstance].user.userID;

    NSString *channelName = [NSString stringWithFormat:@"player-session-%@", playerID];

    // DDLogCInfo(<#frmt, ...#>)
    DDLogCInfo(@"channel name %@", channelName);

    _client = [PTPusher pusherWithKey:QZBPusherKey delegate:self encrypted:YES];

    _client.reconnectDelay = 1;

    PTPusherChannel *channel = [_client subscribeToChannelNamed:channelName];
    self.channel = channel;

    // PTPusherChannel *presentChannel = [_client
    // subscribeToPresenceChannelNamed:@"presence-test"];

    self.yetStarted = NO;

    __weak typeof(self) weakSelf = self;

    [channel bindToEventNamed:@"game-start"
              handleWithBlock:^(PTPusherEvent *channelEvent) {

                DDLogInfo(@"need start game!!");

                if (!self.yetStarted) {
                  self.yetStarted = YES;
                  dispatch_after(
                      dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1 * NSEC_PER_SEC)),
                      dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter]
                            postNotificationName:@"QZBOnlineGameNeedStart"
                                          object:nil];

                      });
                }

              }];
    [channel bindToEventNamed:@"challenge-declined" handleWithBlock:^(PTPusherEvent *channelEvent) {

      NSArray *description = @[@"Оппонент отклонил вызов",
          @"Попробуйте сыграть с другим пользователем"];

      [[NSNotificationCenter defaultCenter]
          postNotificationName:QZBPusherChallengeDeclined
                        object:description];
    }];

    [channel bindToEventNamed:@"opponent-answer"
              handleWithBlock:^(PTPusherEvent *channelEvent) {

                [weakSelf oppomentAnswered:channelEvent.data];

              }];

    [_client connect];
  }
  return self;
}

- (void)dealloc {
  //  [self closeConnection];
  DDLogInfo(@"online worker dealloc ");

  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)oppomentAnswered:(NSDictionary *)pusherDict {
  DDLogInfo(@"%@", pusherDict);

  NSNumber *num = nil;
  NSNumber *time = nil;
  if (pusherDict[@"answer_id"]) {
    num = pusherDict[@"answer_id"];
  }

  if (pusherDict[@"answer_time"]) {
    time = pusherDict[@"answer_time"];
  }

  if (![num isEqual:[NSNull null]] && ![time isEqual:[NSNull null]]) {
    DDLogInfo(@"%@  %@", num, time);

    NSUInteger answerNum = [num unsignedIntegerValue];
    NSUInteger answerTime = [time unsignedIntegerValue];
    NSInteger questID = [pusherDict[@"game_question_id"] integerValue];
    DDLogInfo(@"%ld", (long) questID);

    if ([QZBSessionManager sessionManager].currentQuestion.questionId == questID) {
      [[QZBSessionManager sessionManager]
          opponentUserAnswerCurrentQuestinWithAnswerNumber:answerNum
                                                      time:answerTime];
    } else {
      QZBQuestion *quest = [[QZBSessionManager sessionManager] findQZBQuestionWithID:questID];

      if (quest) {
        DDLogInfo(@"quest %@", quest);

        [[QZBSessionManager sessionManager] opponentAnswerNotInTimeQuestion:quest
                                                               AnswerNumber:answerNum
                                                                       time:answerTime];
      }
    }
  } else {

    DDLogError(@"errr");
  }
}

- (void)pusher:(PTPusher *)pusher didSubscribeToChannel:(PTPusherChannel *)channel {
  if ([channel isEqual:self.channel]) {
    DDLogInfo(@"subscribed");

    [[NSNotificationCenter defaultCenter] postNotificationName:@"subscribedToChanel"
                                                        object:nil];
  }
}

- (void)pusher:(PTPusher *)client connectionDidConnect:(PTPusherConnection *)connection {
}

- (void) pusher:(PTPusher *)pusher
     connection:(PTPusherConnection *)connection
failedWithError:(NSError *)error {
  [self handleDisconnectionWithError:error];
}

- (void)        pusher:(PTPusher *)pusher
            connection:(PTPusherConnection *)connection
didDisconnectWithError:(NSError *)error
  willAttemptReconnect:(BOOL)willAttemptReconnect {
  if (!willAttemptReconnect) {
    [self handleDisconnectionWithError:error];
  }
}

//- (void)pusher:(PTPusher *)pusher willAuthorizeChannelWithRequest:(NSMutableURLRequest *)request {
//    [request setValue:@"some-authentication-token"
//        forHTTPHeaderField:@"X-MyCustom-AuthTokenHeader"];
//}

- (void)handleDisconnectionWithError:(NSError *)error {

  DDLogWarn(@"pusher problems");

  NSArray *description = @[@"Ошибка связи",
      @"Проверьте подключение к интернету"];

  [[NSNotificationCenter defaultCenter] postNotificationName:QZBPusherConnectionProblrms

                                                      object:description];

  Reachability *reachability =
      [Reachability reachabilityWithHostname:self.client.connection.URL.host];

  if (error && [error.domain isEqualToString:PTPusherFatalErrorDomain]) {
    DDLogWarn(@"FATAL PUSHER ERROR, COULD NOT CONNECT! %@", error);
  } else {
    if ([reachability isReachable]) {
      // we do have reachability so let's wait for a set delay before trying
      // again
      [self.client performSelector:@selector(connect) withObject:nil afterDelay:5];
    } else {
      // we need to wait for reachability to change
      [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(reachabilityChanged:)
                                                   name:kReachabilityChangedNotification
                                                 object:reachability];

      [reachability startNotifier];
    }
  }
}

- (void)reachabilityChanged:(NSNotification *)note {
  Reachability *reachability = [note object];

  if ([reachability isReachable]) {
    // we're reachable, we can try and reconnect, otherwise keep waiting
    [self.client connect];

    // stop watching for reachability changes
    [reachability stopNotifier];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kReachabilityChangedNotification
                                                  object:reachability];
  }
}

- (void)closeConnection {
  DDLogInfo(@"close connection");
  [_channel unsubscribe];
  [_client disconnect];

  DDLogInfo(@" client %@  connection %@", _client, _channel);
}

@end
