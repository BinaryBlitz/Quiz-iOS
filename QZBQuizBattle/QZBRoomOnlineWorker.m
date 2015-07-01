//
//  QZBRoomOnlineWorker.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 01/07/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRoomOnlineWorker.h"

#import <Pusher/Pusher.h>
#import "QZBRoom.h"

#import <DDLog.h>

#import "Reachability.h"

#import "QZBSession.h"
#import "QZBSessionManager.h"

NSString *const QZBNeedStartRoomGame = @"NeedStartRoomGame";
NSString *const QZBNewParticipantJoinedRoom = @"NewParticipantJoinedRoom";

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface QZBRoomOnlineWorker () <PTPusherDelegate>

@property (strong, nonatomic) PTPusher *client;
@property (strong, nonatomic) PTPusherChannel *channel;
@property (assign, nonatomic) BOOL yetStarted;

@end

@implementation QZBRoomOnlineWorker

- (instancetype)initWithRoom:(QZBRoom *)room {
    self = [super init];
    if (self) {
        // NSNumber *playerID = [QZBCurrentUser sharedInstance].user.userID;

        NSNumber *roomID = room.roomID;

        NSString *channelName = [NSString stringWithFormat:@"room-%@", roomID];

        // DDLogCInfo(<#frmt, ...#>)
        DDLogCInfo(@"room channel name %@", channelName);

        _client = [PTPusher pusherWithKey:@"d982e4517caa41cf637c" delegate:self encrypted:YES];

        _client.reconnectDelay = 1;

        PTPusherChannel *channel = [_client subscribeToChannelNamed:channelName];
        self.channel = channel;

        // PTPusherChannel *presentChannel = [_client
        // subscribeToPresenceChannelNamed:@"presence-test"];

        self.yetStarted = NO;

        __weak typeof(self) weakSelf = self;

        [channel
            bindToEventNamed:@"game-start"
             handleWithBlock:^(PTPusherEvent *channelEvent) {

                 DDLogCVerbose(@"channel event %@", channelEvent.data);

                 QZBSession *session = [[QZBSession alloc] initWIthDictionary:channelEvent.data];

                 [[QZBSessionManager sessionManager] setSession:session];
                 [[QZBSessionManager sessionManager] removeBotOrOnlineWorker];

                 [[NSNotificationCenter defaultCenter] postNotificationName:QZBNeedStartRoomGame
                                                                     object:nil];

                 NSLog(@"%@", session);
             }];

        [channel bindToEventNamed:@"new-participant"
                  handleWithBlock:^(PTPusherEvent *channelEvent) {
                      [[NSNotificationCenter defaultCenter]
                          postNotificationName:QZBNewParticipantJoinedRoom
                                        object:nil];
                  }];

        //        [channel bindToEventNamed:@"game-start"
        //                  handleWithBlock:^(PTPusherEvent *channelEvent) {
        //
        //                      DDLogInfo(@"need start game!!");
        //
        //                      if (!self.yetStarted) {
        //                          self.yetStarted = YES;
        //                          dispatch_after(
        //                                         dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 *
        //                                         NSEC_PER_SEC)),
        //                                         dispatch_get_main_queue(), ^{
        //                                             [[NSNotificationCenter defaultCenter]
        //                                              postNotificationName:@"QZBOnlineGameNeedStart"
        //                                              object:nil];
        //
        //                                         });
        //                      }
        //
        //                  }];
        //        [channel bindToEventNamed:@"challenge-declined" handleWithBlock:^(PTPusherEvent
        //        *channelEvent) {
        //
        //            NSArray *description = @[@"Оппонент отклонил вызов",
        //                                     @"Попробуйте сыграть с другим пользователем"];
        //
        //            [[NSNotificationCenter defaultCenter]
        //             postNotificationName:QZBPusherChallengeDeclined
        //             object:description];
        //        }];
        //
        //        [channel bindToEventNamed:@"opponent-answer"
        //                  handleWithBlock:^(PTPusherEvent *channelEvent) {
        //
        //                      [weakSelf oppomentAnswered:channelEvent.data];
        //
        //                  }];

        [_client connect];
    }
    return self;
}

- (void)pusher:(PTPusher *)pusher didSubscribeToChannel:(PTPusherChannel *)channel {
    if ([channel isEqual:self.channel]) {
        DDLogInfo(@"subscribed");

        [[NSNotificationCenter defaultCenter] postNotificationName:@"subscribedToChanel"
                                                            object:nil];
    }
}

- (void)pusher:(PTPusher *)pusher
         connection:(PTPusherConnection *)connection
    failedWithError:(NSError *)error {
    [self handleDisconnectionWithError:error];
}

- (void)pusher:(PTPusher *)pusher
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

    NSArray *description = @[ @"Ошибка связи", @"Проверьте подключение к "
                                                          @"интернету" ];

    //    [[NSNotificationCenter defaultCenter] postNotificationName:QZBPusherConnectionProblrms
    //
    //                                                        object:description];
    // REDO

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
