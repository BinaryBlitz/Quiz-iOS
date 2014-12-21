//
//  QZBSession.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 13/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import "QZBSession.h"

static const NSUInteger QZBTimeForAnswer = 10;
static const NSUInteger QZBResultForRightAnswer = 10;


@interface QZBSession ()

@property(nonatomic, strong) NSArray *questions;
@property(nonatomic, strong) QZBUserInSession *firstUser;
@property(nonatomic, strong) QZBUserInSession *opponentUser;
@property(nonatomic, assign) NSUInteger currentQestion;
@property(nonatomic, strong) NSArray *firstUserAnswers;
@property(nonatomic, strong) NSArray *oponentUserAnswers;


@end

@implementation QZBSession

#pragma mark - init
- (instancetype)initWithQestions:(NSArray *)qestions
                           first:(QZBUser *)firstUser
                    opponentUser:(QZBUser *)opponentUser {
  self = [super init];
  if (self) {
    self.questions = qestions;
    self.firstUser = [[QZBUserInSession alloc] initWithUser:firstUser];
    self.opponentUser = [[QZBUserInSession alloc] initWithUser:opponentUser];
    self.currentQestion = 0;
  }
  return self;
}

#pragma mark - checking answers

- (BOOL)isAnswerRightForQestion:(QZBQuestion *)qestion
                         answer:(QZBAnswer *)answer {
  
  if (qestion.rightAnswer == answer.answerNum) {
    
    return YES;
    
  } else {
    
    return NO;
    
  }
}

- (NSUInteger)scoreIsRightAnswer:(BOOL)isRight
                          isLast:(BOOL)isLast
                      answerTime:(QZBAnswer *)answer {
  NSUInteger result = 0;

  if (isRight) {
    
    result = QZBResultForRightAnswer + QZBTimeForAnswer - answer.time;
    
    if (isLast) {
      
      result *= 2;
      
    }
  }
  return result;
}

//вызывается при ответе пользователем на вопрос
- (void)gaveAnswerByUser:(QZBUserInSession *)user
              forQestion:(QZBQuestion *)qestion
                  answer:(QZBAnswer *)answer {
  
  BOOL isRight = [self isAnswerRightForQestion:qestion answer:answer];
  BOOL isLast = NO;
  
  if ([self.questions indexOfObject:qestion] == ([self.questions count] - 1)) {
    isLast = YES;
  }

  NSUInteger score =
      [self scoreIsRightAnswer:isRight isLast:isLast answerTime:answer];

  user.currentScore += score;
  
  QZBQuestionWithUserAnswer *qAndA =
      [[QZBQuestionWithUserAnswer alloc] initWithQestion:qestion answer:answer];

  [user.userAnswers addObject:qAndA];
}

- (QZBWinnew)getWinner {
  
  if (self.firstUser.currentScore > self.opponentUser.currentScore) {
    return QZBWinnerFirst;
  } else if (self.firstUser.currentScore < self.opponentUser.currentScore) {
    return QZBWinnerOpponent;
  } else {
    return QZBWinnerNone;
  }
  
}

@end
