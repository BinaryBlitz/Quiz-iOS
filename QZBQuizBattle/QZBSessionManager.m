//
//  QZBSessionManager.m
//  QZBQuizBattle
//
// Менеджер сессии, контроллер общается именно с менеджером
//
//  Created by Andrey Mikhaylov on 17/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import "QZBSessionManager.h"


@interface QZBSessionManager()

@property (strong, nonatomic) QZBSession *gameSession;
@property (strong, nonatomic) QZBQuestion *currentQuestion;
@property (assign, nonatomic) BOOL answered;
@property (assign, nonatomic) BOOL isDoubled;

@property (strong, nonatomic) NSDate *startTime;
@property (strong, nonatomic) NSTimer *questionTimer;
@property (assign, nonatomic) NSUInteger currentTime;

@property (assign, nonatomic) NSUInteger firstUserScore;
@property (assign, nonatomic) NSUInteger secondUserScore;

@end

@implementation QZBSessionManager

- (instancetype)init
{
  self = [super init];
  if (self) {
    
    NSLog(@"init");
    _sessionTime = 10;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTimeStartNotification:)
                                                 name:@"QZBStartTimeCounting"
                                               object:nil];
  }
  return self;
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  //[super dealloc];
}

+ (instancetype)sessionManager{
  
  static id sharedInstance = nil;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[self alloc] init];
  });
  
  
  
  return sharedInstance;
}

-(void)setSession:(QZBSession *)session{
  _gameSession = session;
  self.currentQuestion = [session.qestions firstObject];
}


-(void)timeCountingStart{
  self.questionTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(updateTime:)
                                                userInfo:nil
                                                 repeats:YES];
}

-(void)updateTime:(NSTimer *)timer{
  
  self.currentTime++;
 
  
  if(self.currentTime<10){
    
    
    NSLog(@"%lu", (unsigned long)self.currentTime);
    
  }else{
    
    if (timer != nil)
    {
      [timer invalidate];
      timer = nil;
      [self postNotificationNeedUnshow];
    }
   
    self.answered = YES;
  }
  
  
}

//TODO: count answerTime

-(void)newQuestionStart{
  self.answered = NO;
  [self timeCountingStart];
  
}

-(void)firstUserAnswerCurrentQuestinWithAnswerNumber:(NSUInteger) answerNum time:(NSUInteger)time{
  
  QZBAnswer *answer = [[QZBAnswer alloc] initWithAnswerNumber:answerNum
                                                   answerTime:time];
  
  [self.gameSession gaveAnswerByUser:self.gameSession.firstUser
                          forQestion:self.currentQuestion
                              answer:answer];
  
  NSLog(@"%ld",(unsigned long)self.gameSession.firstUser.currentScore);
  self.firstUserScore = self.gameSession.firstUser.currentScore;
  
  /*
  if(self.questionTimer!=nil){
    [self.questionTimer invalidate];
     self.questionTimer = nil;
  }*/
  self.answered = YES;
  
  
}

-(void)firstUserAnswerCurrentQuestinWithAnswerNumber:(NSUInteger) answerNum{
  
  [self firstUserAnswerCurrentQuestinWithAnswerNumber:answerNum time:self.currentTime];
  
}

-(void)receiveTimeStartNotification:(NSNotification *) notification{
  
  if ([[notification name] isEqualToString:@"QZBStartTimeCounting"]){
    
    NSLog(@"notification");
    [self timeCountingStart];
    
  }
  
}

#pragma mark - post notifications

-(void)postNotificationNeedUnshow{
  
  NSUInteger index = [self.gameSession.qestions indexOfObject:self.currentQuestion];
  
  if(index < [self.gameSession.qestions count] - 1){
  
    self.currentTime = 0;
    index++;
    self.currentQuestion = [self.gameSession.qestions objectAtIndex:index];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"QZBNeedUnshowQuestion" object:self];
  
  } else{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"QZBNeedFinishSession" object:self];
  }
}


@end
