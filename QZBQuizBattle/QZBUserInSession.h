//
//  QZBUser.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 13/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QZBUser;
@class QZBQuestion;
@class QZBQuestionWithUserAnswer;

@interface QZBUserInSession : NSObject

@property (strong, nonatomic) QZBUser *user;
@property (nonatomic, assign) NSUInteger currentScore;
@property (nonatomic, strong) NSMutableArray *userAnswers;  // QZBQuestionWithUserAnswer

- (instancetype)initWithUser:(QZBUser *)user;

- (BOOL)couldAnswerAfterTime:(QZBQuestion *)question;
- (QZBQuestionWithUserAnswer *)findQuestionAndAnswerWithQuestion:(QZBQuestion *)question;

@end
