//
//  QZBOnlineSessionWorker.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 29/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBOnlineSessionWorker.h"
#import <Pusher/Pusher.h>
#import "QZBSessionManager.h"
#import "QZBCurrentUser.h"
#import "QZBUser.h"
#import "QZBAnswerTextAndID.h"

@interface QZBOnlineSessionWorker () <PTPusherDelegate>

@property(strong, nonatomic) PTPusher *client;
@property(strong, nonatomic) PTPusherChannel *channel;
@property(assign, nonatomic) BOOL yetStarted;

@end

@implementation QZBOnlineSessionWorker

- (instancetype)init {
  self = [super init];
  if (self) {
    NSLog(@"online worker init");
    
    NSNumber *playerID = [QZBCurrentUser sharedInstance].user.user_id;

    NSString *channelName =
        [NSString stringWithFormat:@"player-session-%@", playerID];

    NSLog(@"channel name %@", channelName);

    _client = [PTPusher pusherWithKey:@"d982e4517caa41cf637c"
                                 delegate:self
                                encrypted:YES];

    PTPusherChannel *channel = [_client subscribeToChannelNamed:channelName];
    self.channel = channel;

    [_client connect];

    // NSLog(@"%@", self.channel);

    self.yetStarted = NO;
    
    [channel
        bindToEventNamed:@"game-start"
         handleWithBlock:^(PTPusherEvent *channelEvent) {
           

             NSLog(@"need start game!!");
           
           if(!self.yetStarted){
             self.yetStarted = YES;
             dispatch_after(
                 dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
                 dispatch_get_main_queue(), ^{
                     [[NSNotificationCenter defaultCenter]
                         postNotificationName:@"QZBOnlineGameNeedStart"
                                       object:nil];

                 });
           }
           
         }];

    [channel
        bindToEventNamed:@"opponent-answer"
         handleWithBlock:^(PTPusherEvent *channelEvent) {

             NSDictionary *pusherDict = channelEvent.data;

             NSLog(@"%@", pusherDict);

           //  NSInteger questID = [pusherDict[@"question_id"] integerValue];

             //if ([QZBSessionManager sessionManager].currentQuestion.questionId == questID) {
           NSNumber *num = nil;
           NSNumber *time = nil;
           if(pusherDict[@"answer_id"]){
             num = pusherDict[@"answer_id"];
           }
           
           if(pusherDict[@"answer_time"]){
             time = pusherDict[@"answer_time"];
             
           }
           
           
           

           if(![num isEqual:[NSNull null]] && ![time isEqual:[NSNull null]]){
             
             NSLog(@"%@  %@",num, time );
             
             NSUInteger answerNum =
             [num unsignedIntegerValue];
             NSUInteger answerTime =
             [time unsignedIntegerValue];
             NSInteger questID = [pusherDict[@"game_session_question_id"] integerValue];
             NSLog(@"%ld", (long)questID);

             if ([QZBSessionManager sessionManager].currentQuestion.questionId == questID) {
             
               [[QZBSessionManager sessionManager]
                   opponentUserAnswerCurrentQuestinWithAnswerNumber:answerNum
                                                               time:answerTime];
             }
           } else{
             
             QZBAnswerTextAndID *answ= [[QZBSessionManager sessionManager].currentQuestion.answers firstObject];
             
                                      
             
             [[QZBSessionManager sessionManager] opponentUserAnswerCurrentQuestinWithAnswerNumber:answ.answerID];
             
           }
          //   }

         }];
  }
  return self;
}

- (void)pusher:(PTPusher *)pusher didSubscribeToChannel:(PTPusherChannel *)channel{
  if([channel isEqual:self.channel]){
    NSLog(@"subscribed");
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"subscribedToChanel" object:nil];
  }
}

-(void)closeConnection{
  
  NSLog(@"close connection");
  [_channel unsubscribe];
  [_client disconnect];
  
  NSLog(@" client %@  connection %@", _client, _channel);
  
}

- (void)dealloc {
  [self closeConnection];
  NSLog(@"online worker dealloc ");
 
}

@end
