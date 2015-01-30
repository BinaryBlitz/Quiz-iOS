//
//  QZBSessionManager.m
//  QZBQuizBattle
//
// Менеджер сессии, контроллер общается именно с менеджером сессии, а не с самой сессией
//
//  Created by Andrey Mikhaylov on 17/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import "QZBSessionManager.h"
#import "QZBUser.h"
#import "QZBOnlineSessionWorker.h"

#define OFFLINE YES

@interface QZBSessionManager ()

@property(strong, nonatomic) QZBSession *gameSession;
@property(strong, nonatomic) QZBQuestion *currentQuestion;
@property(assign, nonatomic) NSUInteger roundNumber;
@property(assign, nonatomic) BOOL isDoubled;

@property(copy, nonatomic)NSString *firstUserName;
@property(copy, nonatomic)NSString *opponentUserName;

@property(strong, nonatomic) NSDate *startTime;
@property(strong, nonatomic) NSTimer *questionTimer;
@property(assign, nonatomic) NSUInteger currentTime;

@property(assign, nonatomic) NSUInteger firstUserScore;
@property(assign, nonatomic) NSUInteger secondUserScore;

@property(assign, nonatomic) BOOL didFirstUserAnswered;
@property(assign, nonatomic) BOOL didOpponentUserAnswered;

@property(assign, nonatomic) QZBQuestionWithUserAnswer *firstUserLastAnswer;
@property(assign, nonatomic) QZBQuestionWithUserAnswer *opponentUserLastAnswer;

@property(strong, nonatomic) QZBOpponentBot *bot;
@property(strong, nonatomic) QZBOnlineSessionWorker *onlineSessionWorker;

@end

@implementation QZBSessionManager

- (instancetype)init {
  self = [super init];
  if (self) {
    NSLog(@"init");
    _sessionTime = 10;

    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(receiveTimeStartNotification:)
               name:@"QZBStartTimeCounting"
             object:nil];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  //[super dealloc];
}

+ (instancetype)sessionManager {
  static id sharedInstance = nil;

  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{ sharedInstance = [[self alloc] init]; });

  return sharedInstance;
}

- (void)setSession:(QZBSession *)session {
  
  if(_gameSession){
    return;
  }
  
  _gameSession = session;
  self.currentQuestion = [session.questions firstObject];

  // TODO timer invalidate

  self.firstUserLastAnswer = nil;
  self.firstUserLastAnswer = nil;

  self.firstUserScore = 0;
  self.secondUserScore = 0;
  self.didFirstUserAnswered = NO;
  self.didOpponentUserAnswered = NO;
  self.questionTimer = nil;
  self.roundNumber = 1;
  self.isDoubled = NO;
  
  self.firstUserName = session.firstUser.user.name;
}

- (void)setBot:(QZBOpponentBot *)bot {
  if(_bot && _onlineSessionWorker){
    return;
  }else{
  _bot = bot;
  }
}

-(void)setOnlineSessionWorker:(QZBOnlineSessionWorker *)onlineSessionWorker{
  if(_onlineSessionWorker && _bot){
    return;
  } else{
  _onlineSessionWorker = onlineSessionWorker;
  }
}

- (void)timeCountingStart {
  
  if(!self.questionTimer){
  self.questionTimer =
      [NSTimer scheduledTimerWithTimeInterval:1.0
                                       target:self
                                     selector:@selector(updateTime:)
                                     userInfo:nil
                                      repeats:YES];}
  
}

- (void)updateTime:(NSTimer *)timer {
  self.currentTime++;

  // NSLog(@"%lu",(unsigned long)self.currentTime);
  if (self.currentTime < 10) {
    NSLog(@"%ld",(unsigned long)self.currentTime);
  } else {
    if (self.questionTimer != nil) {
      self.didFirstUserAnswered = YES;
      self.didOpponentUserAnswered = YES;//чтобы нельзя было ответить пока переключаются вопросы
      [self.questionTimer invalidate];
      self.questionTimer = nil;
      [self postNotificationNeedUnshow];
    }
  }
}

// TODO: count answerTime
//вызывается для запуска таймера игровой сессии
- (void)newQuestionStart {
  // self.answered = NO;
  self.currentTime = 0;
  self.didFirstUserAnswered = NO;
  self.didOpponentUserAnswered = NO;
  

  [self timeCountingStart];

  if (self.bot) {
    NSLog(@"new questionStarted");
    NSUInteger questNum =
        [self.gameSession.questions indexOfObject:self.currentQuestion];
    
    NSNumber *questionNumber = [NSNumber numberWithUnsignedInteger:questNum];

    [[NSNotificationCenter defaultCenter]
        postNotificationName:@"QZBNewQuestionTimeCountingStart"
                      object:questionNumber];
  }
}

#pragma mark - users answes questions

//главный метод для первого пользователя
- (void)firstUserAnswerCurrentQuestinWithAnswerNumber:(NSUInteger)answerNum {
  if (self.didFirstUserAnswered) {
    return;
  }

  self.didFirstUserAnswered = YES;
  [self firstUserAnswerCurrentQuestinWithAnswerNumber:answerNum
                                                 time:self.currentTime];
}

//главный метод для второго пользователя
- (void)opponentUserAnswerCurrentQuestinWithAnswerNumber:(NSUInteger)answerNum {
 /* if (self.didOpponentUserAnswered) {
    return;
  }

  self.didOpponentUserAnswered = YES;*/

  [self opponentUserAnswerCurrentQuestinWithAnswerNumber:answerNum
                                                    time:self.currentTime];
}

//метод для подсчета очков первого пользователя
- (void)firstUserAnswerCurrentQuestinWithAnswerNumber:(NSUInteger)answerNum
                                                 time:(NSUInteger)time {
  //отправляет данные о ходе пользователя
  [[QZBServerManager sharedManager]
      PATCHSessionQuestionWithID:self.currentQuestion.questionId
                          answer:answerNum
                            time:time
                       onSuccess:nil
                       onFailure:nil];

  [self someAnswerCurrentQuestinUser:self.gameSession.firstUser
                        AnswerNumber:answerNum
                                time:time];

  self.firstUserScore = self.gameSession.firstUser.currentScore;

  self.firstUserLastAnswer =
      [self.gameSession.firstUser.userAnswers lastObject];

  [self checkNeedUnshow];
}

// метод для подсчета очков второго пользователя
- (void)opponentUserAnswerCurrentQuestinWithAnswerNumber:(NSUInteger)answerNum
                                                    time:(NSUInteger)time {
  if (self.didOpponentUserAnswered) {
    return;
  }
  self.didOpponentUserAnswered = YES;
  
  [self someAnswerCurrentQuestinUser:self.gameSession.opponentUser
                        AnswerNumber:answerNum
                                time:time];

  self.secondUserScore = self.gameSession.opponentUser.currentScore;
  self.opponentUserLastAnswer =
      [self.gameSession.opponentUser.userAnswers lastObject];

  [[NSNotificationCenter defaultCenter]
      postNotificationName:@"QZBOpponentUserMadeChoose"
                    object:self];
  [self checkNeedUnshow];
}

//для подсчета очков в сессии для первого или второо
- (void)someAnswerCurrentQuestinUser:(QZBUserInSession *)user
                        AnswerNumber:(NSUInteger)answerNum
                                time:(NSUInteger)time {
  QZBAnswer *answer =
      [[QZBAnswer alloc] initWithAnswerNumber:answerNum answerTime:time];

  [self.gameSession gaveAnswerByUser:user
                          forQestion:self.currentQuestion
                              answer:answer];
}

- (void)checkNeedUnshow {
  // NSLog(@"checking first %d seconf %d", self.didFirstUserAnswered,
  // self.didOpponentUserAnswered);
  if (self.didFirstUserAnswered && self.didOpponentUserAnswered ) {
    if (self.questionTimer != nil) {
      [self.questionTimer invalidate];
      self.questionTimer = nil;
    }

    [self postNotificationNeedUnshow];
  }
}

- (void)receiveTimeStartNotification:(NSNotification *)notification {
  if ([[notification name] isEqualToString:@"QZBStartTimeCounting"]) {
    NSLog(@"notification");
    [self timeCountingStart];
  }
}

#pragma mark - post notifications

- (void)postNotificationNeedUnshow {
  NSUInteger index =
      [self.gameSession.questions indexOfObject:self.currentQuestion];
  if (!self.didFirstUserAnswered) {
    [self.gameSession gaveAnswerByUser:self.gameSession.firstUser
                            forQestion:self.currentQuestion
                                answer:nil];
  }

  if (!self.didOpponentUserAnswered) {
    [self.gameSession gaveAnswerByUser:self.gameSession.opponentUser
                            forQestion:self.currentQuestion
                                answer:nil];
  }

  self.firstUserLastAnswer =
      [self.gameSession.firstUser.userAnswers lastObject];
  self.opponentUserLastAnswer =
      [self.gameSession.opponentUser.userAnswers lastObject];

  self.roundNumber = index + 2;

  if (index < [self.gameSession.questions count] - 1) {
    // self.currentTime = 0;
    index++;
    self.currentQuestion = [self.gameSession.questions objectAtIndex:index];

    [[NSNotificationCenter defaultCenter]
        postNotificationName:@"QZBNeedUnshowQuestion"
                      object:self];

  } else {
    QZBWinnew winner = [self.gameSession getWinner];

    NSString *resultOfGame = @"";

    switch (winner) {
      case QZBWinnerFirst:
        resultOfGame = @"Победа";
        break;
      case QZBWinnerOpponent:
        resultOfGame = @"Поражение";
        break;

      case QZBWinnerNone:
        resultOfGame = @"Ничья";
        break;
      default:
        resultOfGame = @"Проблемы";  //исправить
        break;
    }

    [[NSNotificationCenter defaultCenter]
        postNotificationName:@"QZBNeedFinishSession"
                      object:resultOfGame];

    [self closeSession];
  }
}

- (void)closeSession {
  if (self.questionTimer != nil) {
    [self.questionTimer invalidate];
    self.questionTimer = nil;
  }

  self.gameSession = nil;
  self.bot = nil;
  if(self.onlineSessionWorker){
    [self.onlineSessionWorker closeConnection];
  }
  self.onlineSessionWorker = nil;
}

@end
