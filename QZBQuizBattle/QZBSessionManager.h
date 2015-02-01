//
//  QZBSessionManager.h
//  QZBQuizBattle
//
// Менеджер сессии, контроллер общается именно с менеджером
//
//  Created by Andrey Mikhaylov on 17/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QZBSession.h"
#import "QZBOpponentBot.h"
#import "QZBServerManager.h"

@class QZBOnlineSessionWorker;
@interface QZBSessionManager : NSObject

@property(strong, nonatomic, readonly) QZBQuestion *currentQuestion;
@property(assign, nonatomic, readonly) NSUInteger currentTime;

@property(assign, nonatomic, readonly) NSUInteger firstUserScore;
@property(assign, nonatomic, readonly) NSUInteger secondUserScore;

@property(copy, nonatomic, readonly)NSString *firstUserName;
@property(copy, nonatomic, readonly)NSString *opponentUserName;

@property(assign, nonatomic, readonly) NSUInteger roundNumber;
@property(assign, nonatomic, readonly) BOOL isDoubled;
@property(assign, nonatomic, readonly) NSUInteger sessionTime;

@property(assign, nonatomic, readonly)
    QZBQuestionWithUserAnswer *firstUserLastAnswer;
@property(assign, nonatomic, readonly)
    QZBQuestionWithUserAnswer *opponentUserLastAnswer;
@property(strong, nonatomic, readonly) NSMutableArray *askedQuestions;//QZBQuestion

- (void)setSession:(QZBSession *)session;
- (void)setBot:(QZBOpponentBot *)bot;
- (void)setOnlineSessionWorker:(QZBOnlineSessionWorker *)onlineSessionWorker;

+ (instancetype)sessionManager;

- (void)newQuestionStart;

- (void)firstUserAnswerCurrentQuestinWithAnswerNumber:(NSUInteger)answerNum;

- (void)opponentUserAnswerCurrentQuestinWithAnswerNumber:(NSUInteger)answerNum;

- (void)opponentUserAnswerCurrentQuestinWithAnswerNumber:(NSUInteger)answerNum
                                                    time:(NSUInteger)time;

- (void)closeSession;


#pragma mark - online methods

-(QZBQuestion *)findQZBQuestionWithID:(NSInteger)questionID;

-(void)opponentAnswerNotInTimeQuestion:(QZBQuestion *)question
                          AnswerNumber:(NSUInteger)answerNum
                                  time:(NSUInteger)time;
@end
