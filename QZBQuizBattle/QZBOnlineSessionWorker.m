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

@interface QZBOnlineSessionWorker () <PTPusherDelegate>

@property(strong, nonatomic) PTPusher *client;
@property(strong, nonatomic) PTPusherChannel *channel;

@end

@implementation QZBOnlineSessionWorker

- (instancetype)init {
  self = [super init];
  if (self) {
    NSNumber *playerID = [QZBCurrentUser sharedInstance].user.user_id;

    NSString *channelName =
        [NSString stringWithFormat:@"player-session-%@", playerID];

    NSLog(@"channel name %@", channelName);

    self.client = [PTPusher pusherWithKey:@"d982e4517caa41cf637c"
                                 delegate:self
                                encrypted:YES];

    self.channel = [_client subscribeToChannelNamed:channelName];

    [self.client connect];

    // NSLog(@"%@", self.channel);

    [self.channel
        bindToEventNamed:@"game-start"
         handleWithBlock:^(PTPusherEvent *channelEvent) {

             NSLog(@"need start game!!");
             dispatch_after(
                 dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
                 dispatch_get_main_queue(), ^{
                     [[NSNotificationCenter defaultCenter]
                         postNotificationName:@"QZBOnlineGameNeedStart"
                                       object:nil];

                 });
           
         }];

    [self.channel
        bindToEventNamed:@"opponent-answer"
         handleWithBlock:^(PTPusherEvent *channelEvent) {

             NSDictionary *pusherDict = channelEvent.data;

             NSLog(@"%@", pusherDict);

             NSInteger questID = [pusherDict[@"question_id"] integerValue];

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
             
             
               [[QZBSessionManager sessionManager]
                   opponentUserAnswerCurrentQuestinWithAnswerNumber:answerNum
                                                               time:answerTime];
           }
          //   }

         }];
  }
  return self;
}

- (void)dealloc {
  [self.client disconnect];
}

@end