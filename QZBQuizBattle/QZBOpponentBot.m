//
//  QZBOpponentBot.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 19/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import "QZBOpponentBot.h"
#import "QZBSessionManager.h"

@interface QZBOpponentBot ()

@property(strong, nonatomic) NSArray *answersWithTime;  // array of QZBAnswer
@property(assign, nonatomic) NSUInteger questionNumber;

@end

@implementation QZBOpponentBot

#pragma mark - lifeTime
- (instancetype)initWithAnswersAndTimes:(NSArray *)answersWithTime {
  self = [super init];
  if (self) {
    self.answersWithTime = answersWithTime;
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(questionDidStartWithNUmber:)
               name:@"QZBNewQuestionTimeCountingStart"
             object:nil];
  }
  return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
  NSArray *session_questions = [dict objectForKey:@"game_session_questions"];

  NSMutableArray *answersWithTime = [NSMutableArray array];

  for (NSDictionary *questDict in session_questions) {
    NSUInteger answerID =
        [[questDict objectForKey:@"opponent_answer_id"] unsignedIntegerValue];
    NSUInteger time =
        [[questDict objectForKey:@"opponent_time"] unsignedIntegerValue];
    
    
    QZBAnswer *answerWithTime =
        [[QZBAnswer alloc] initWithAnswerNumber:answerID answerTime:time];

    [answersWithTime addObject:answerWithTime];
  }

  return [self initWithAnswersAndTimes:answersWithTime];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - auto answer
- (void)questionDidStartWithNUmber:(NSNotification *)notification {
  // NSLog(@"notified");
  if ([[notification name]
          isEqualToString:@"QZBNewQuestionTimeCountingStart"]) {
    if ([notification.object isKindOfClass:[NSNumber class]]) {
      NSLog(@"choosed");

      NSNumber *num = (NSNumber *)notification.object;

      NSUInteger number = [num unsignedIntegerValue];

      QZBAnswer *answerAndTime = [self.answersWithTime objectAtIndex:number];

      dispatch_after(dispatch_time(
                         DISPATCH_TIME_NOW,
                         (int64_t)(answerAndTime.time * NSEC_PER_SEC)),
                     dispatch_get_main_queue(), ^{

          [[QZBSessionManager sessionManager]
              opponentUserAnswerCurrentQuestinWithAnswerNumber:answerAndTime
                                                                   .answerNum];
      });
    }
  }
}

@end
