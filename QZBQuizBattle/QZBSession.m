//
//  QZBSession.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 13/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import "QZBSession.h"
#import "QZBUser.h"
#import "QZBCurrentUser.h"
#import "QZBServerManager.h"
#import "QZBUserProtocol.h"
#import "QZBAnotherUser.h"

static const NSUInteger QZBTimeForAnswer = 10;
static const NSUInteger QZBResultForRightAnswer = 10;

@interface QZBSession ()

@property (strong, nonatomic) NSArray *questions;
@property (strong, nonatomic) QZBUserInSession *firstUser;
@property (strong, nonatomic) QZBUserInSession *opponentUser;
@property (assign, nonatomic) NSUInteger currentQestion;
@property (strong, nonatomic) NSArray *firstUserAnswers;
@property (strong, nonatomic) NSArray *oponentUserAnswers;
@property (assign, nonatomic) NSInteger session_id;
@property (strong, nonatomic) NSNumber *lobbyID;

@property (strong, nonatomic) NSURL *firstUserImageURL;
@property (strong, nonatomic) NSURL *opponentUserImageURL;
@property (assign, nonatomic) NSInteger userBeginingScore;
@property (assign, nonatomic) NSInteger userMultiplier;


@end

@implementation QZBSession

#pragma mark - init
- (instancetype)initWithQestions:(NSArray *)qestions
                           first:(id<QZBUserProtocol>)firstUser
                    opponentUser:(id<QZBUserProtocol>)opponentUser {
    self = [super init];
    if (self) {
        self.questions = qestions;
        self.firstUser = [[QZBUserInSession alloc] initWithUser:firstUser];
        self.opponentUser = [[QZBUserInSession alloc] initWithUser:opponentUser];
        self.currentQestion = 0;
    }
    return self;
}

// redo users
- (instancetype)initWIthDictionary:(NSDictionary *)dict {
    NSMutableArray *questions = [NSMutableArray array];
    NSArray *arrayOfQuestionDicts = [dict objectForKey:@"game_session_questions"];

    self.session_id = [[dict objectForKey:@"id"] integerValue];

    if (dict[@"lobby_id"]) {  //инициализурет айди лобби, нужно для челенджей
        self.lobbyID = dict[@"lobby_id"];
    }

    // NSString *topic = [NSString stringWithFormat:@"%ld", (long)topic_id];

    for (NSDictionary *d in arrayOfQuestionDicts) {
//        NSDictionary *questDict = [d objectForKey:@"question"];
//        NSString *questText = [questDict objectForKey:@"content"];
//        NSInteger questionID = [[d objectForKey:@"id"] integerValue];
//        NSInteger correctAnswer = -1;
//        NSArray *answersDicts = [questDict objectForKey:@"answers"];
//        NSMutableArray *answers = [NSMutableArray array];
//
//        // NSInteger i = 0;
//        for (NSDictionary *answDict in answersDicts) {
//            // NSLog(@"%@", answDict);
//
//            NSString *textOfAnswer = [answDict objectForKey:@"content"];
//            NSInteger answerID = [[answDict objectForKey:@"id"] integerValue];
//            QZBAnswerTextAndID *answerWithId =
//                [[QZBAnswerTextAndID alloc] initWithText:textOfAnswer answerID:answerID];
//
//            [answers addObject:answerWithId];
//            NSNumber *isRight = [answDict objectForKey:@"correct"];
//            if ([isRight isEqual:@(1)]) {
//                correctAnswer = answerID;  //[[answDict objectForKey:@"id"] integerValue];
//            }
//            //  i++;
//        }
//
//        //перемешивает ответы в массиве(json приходит так, что правильный всегда
//        //первый
//        NSUInteger count = [answers count];
//        for (NSUInteger i = 0; i < count; ++i) {
//            NSUInteger nElements = count - i;
//            NSUInteger n = (arc4random() % nElements) + i;
//            [answers exchangeObjectAtIndex:i withObjectAtIndex:n];
//        }
        
        QZBQuestion *question = [[QZBQuestion alloc] initWithDictionary:d];

//        QZBQuestion *question = [[QZBQuestion alloc] initWithTopic:@""
//                                                          question:questText
//                                                           answers:answers
//                                                       rightAnswer:correctAnswer
//                                                        questionID:questionID];

       // NSLog(@"%ld", (long)questionID);
        [questions addObject:question];
    }

    // NSInteger firsUserId = [[dict objectForKey:@"host_id"] integerValue];
    // NSInteger opponentUserId = -1;

    QZBUser *user1 = [QZBCurrentUser sharedInstance].user;


    QZBAnotherUser *opponent = nil;
    opponent = [[QZBAnotherUser alloc] init];
    
    NSDictionary *hostDict = dict[@"host"];
    NSDictionary *opponentDict = dict[@"opponent"];
    
    NSNumber *hostID = hostDict[@"id"];
    
    if ([hostID isEqualToNumber:user1.userID]) {
        self.userBeginingScore = [hostDict[@"points"] integerValue];
        self.userMultiplier = [hostDict[@"multiplier"] integerValue];
        
        
        opponent.name = opponentDict[@"name"];
        
        if ( opponentDict[@"id"]) {
            opponent.userID = opponentDict[@"id"];
        }
        if ( opponentDict[@"avatar_url"] && ![opponentDict[@"avatar_url"] isEqual:[NSNull null]]) {
            NSString *url = [QZBServerBaseUrl stringByAppendingString:opponentDict[@"avatar_url"]];

            opponent.imageURL = [NSURL URLWithString:url];
        } else {
            opponent.imageURL = nil;
        }

    } else {
        self.userBeginingScore = [opponentDict[@"points"] integerValue];
        self.userMultiplier = [opponentDict[@"multiplier"] integerValue];
        
        opponent.name = hostDict[@"name"];
        opponent.userID = hostDict[@"id"];
        if (hostDict[@"avatar_url"] && ![hostDict[@"avatar_url"] isEqual:[NSNull null]]) {
            NSString *url = [QZBServerBaseUrl stringByAppendingString:hostDict[@"avatar_url"]];
            opponent.imageURL = [NSURL URLWithString:url];
        } else {
            opponent.imageURL = nil;
        }
    }

    return [self initWithQestions:questions first:user1 opponentUser:opponent];
}

#pragma mark - checking answers

- (BOOL)isAnswerRightForQestion:(QZBQuestion *)qestion answer:(QZBAnswer *)answer {
    if (qestion.rightAnswer == answer.answerNum) {
        return YES;

    } else {
        return NO;
    }
}

- (NSUInteger)scoreIsRightAnswer:(BOOL)isRight isLast:(BOOL)isLast answerTime:(QZBAnswer *)answer {
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

    NSUInteger score = [self scoreIsRightAnswer:isRight isLast:isLast answerTime:answer];

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
