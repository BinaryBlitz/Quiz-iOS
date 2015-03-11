//
//  QZBSession.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 13/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QZBUserInSession.h"
#import "QZBQuestion.h"
#import "QZBAnswer.h"
#import "QZBQuestionWithUserAnswer.h"
#import "QZBAnswerTextAndID.h"

@class QZBUserInSession;
@class QZBUser;

typedef NS_ENUM(NSInteger, QZBWinnew) { QZBWinnerFirst, QZBWinnerOpponent, QZBWinnerNone };

@interface QZBSession : NSObject

@property (nonatomic, strong, readonly) NSArray *questions;  // QZBQestion
@property (nonatomic, strong, readonly) QZBUserInSession *firstUser;
@property (nonatomic, strong, readonly) QZBUserInSession *opponentUser;

- (instancetype)initWithQestions:(NSArray *)qestions
                           first:(id<QZBUserProtocol> )firstUser
                    opponentUser:(id<QZBUserProtocol> )opponentUser;

- (instancetype)initWIthDictionary:(NSDictionary *)dict;

- (void)gaveAnswerByUser:(QZBUserInSession *)user forQestion:(QZBQuestion *)qestion answer:(QZBAnswer *)answer;
- (QZBWinnew)getWinner;

@end
