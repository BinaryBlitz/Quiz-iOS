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

@interface QZBSessionManager : NSObject

@property(strong, nonatomic, readonly) QZBQuestion *currentQuestion;
@property(assign, nonatomic, readonly) NSUInteger currentTime;

@property(assign, nonatomic, readonly) NSUInteger firstUserScore;
@property(assign, nonatomic, readonly) NSUInteger secondUserScore;

@property(assign, nonatomic, readonly) NSUInteger roundNumber;
@property(assign, nonatomic, readonly) BOOL isDoubled;
@property(assign, nonatomic, readonly) NSUInteger sessionTime;

@property(assign, nonatomic, readonly)
    QZBQuestionWithUserAnswer *firstUserLastAnswer;
@property(assign, nonatomic, readonly)
    QZBQuestionWithUserAnswer *opponentUserLastAnswer;

- (void)setSession:(QZBSession *)session;
- (void)setBot:(QZBOpponentBot *)bot;

+ (instancetype)sessionManager;

- (void)newQuestionStart;

- (void)firstUserAnswerCurrentQuestinWithAnswerNumber:(NSUInteger)answerNum;

- (void)opponentUserAnswerCurrentQuestinWithAnswerNumber:(NSUInteger)answerNum;
@end
