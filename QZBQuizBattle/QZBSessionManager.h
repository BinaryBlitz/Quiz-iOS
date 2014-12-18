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

@interface QZBSessionManager : NSObject


@property (strong, nonatomic, readonly) QZBQuestion *currentQuestion;
@property (assign, nonatomic, readonly) NSUInteger currentTime;

@property (assign, nonatomic, readonly) NSUInteger firstUserScore;
@property (assign, nonatomic, readonly) NSUInteger secondUserScore;

@property (assign, nonatomic, readonly) NSUInteger sessionTime;

-(void)setSession:(QZBSession *)session;

+ (instancetype)sessionManager;

-(void)newQuestionStart;
-(void)firstUserAnswerCurrentQuestinWithAnswerNumber:(NSUInteger) answerNum time:(NSUInteger)time;
-(void)firstUserAnswerCurrentQuestinWithAnswerNumber:(NSUInteger) answerNum;
@end
