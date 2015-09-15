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

//
//мне очень жаль что ооп было нарушено в этом классе((
//

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
@property (copy, nonatomic) NSString *fact;

@property (assign, nonatomic) BOOL isRoom;

@end

@implementation QZBSession

#pragma mark - init
//- (instancetype)initWithQestions:(NSArray *)qestions
//                           first:(id<QZBUserProtocol>)firstUser
//                    opponentUser:(id<QZBUserProtocol>)opponentUser {
//    self = [super init];
//    if (self) {
//        self.questions = qestions;
//        self.firstUser = [[QZBUserInSession alloc] initWithUser:firstUser];
//        self.opponentUser = [[QZBUserInSession alloc] initWithUser:opponentUser];
//        self.currentQestion = 0;
//    }
//    return self;
//}

- (instancetype)initWIthDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        NSMutableArray *questions = [NSMutableArray array];
        
        NSArray *arrayOfQuestionDicts = nil;
        

        
        if(dict[@"game_session_questions"] && ![dict[@"game_session_questions"] isEqual:[NSNull null]]){
            arrayOfQuestionDicts = dict[@"game_session_questions"];
            self.isRoom = NO;
        } else {
            arrayOfQuestionDicts = dict[@"room_questions"];
            self.isRoom = YES;
        }

        self.session_id = [[dict objectForKey:@"id"] integerValue];

        if (dict[@"lobby_id"] && ![dict[@"lobby_id"] isEqual:[NSNull null]]) {  //инициализурет айди лобби, нужно для челенджей
            self.lobbyID = dict[@"lobby_id"];
        }

        if(dict[@"fact"] && ![dict[@"fact"] isEqual:[NSNull null]]){
            self.fact = dict[@"fact"];
        }
        // NSString *topic = [NSString stringWithFormat:@"%ld", (long)topic_id];

        for (NSDictionary *d in arrayOfQuestionDicts) {
            QZBQuestion *question = nil;
            if(self.isRoom){
                question = [[QZBQuestion alloc] initWithDictionary:d[@"room_question"]];
            }else{
                question = [[QZBQuestion alloc] initWithDictionary:d];
            }
            
            //QZBQuestion *question = [[QZBQuestion alloc] initWithDictionary:d];

            [questions addObject:question];
        }

        QZBUser *user1 = [QZBCurrentUser sharedInstance].user;

        QZBAnotherUser *opponent = [[QZBAnotherUser alloc] init];
        // opponent = [[QZBAnotherUser alloc] init];

        NSDictionary *hostDict = dict[@"host"];
        NSDictionary *opponentDict = dict[@"opponent"];
        
        if(hostDict && opponentDict){

        NSNumber *hostID = hostDict[@"id"];

        if ([hostID isEqualToNumber:user1.userID]) {
            self.userBeginingScore = [hostDict[@"points"] integerValue];
            
            if(![hostDict[@"multiplier"] isEqual:[NSNull null]]){
                self.userMultiplier = [hostDict[@"multiplier"] integerValue];
            }else {
                self.userMultiplier = 1;
            }

            if (![opponentDict[@"username"] isEqual:[NSNull null]] && opponentDict[@"username"]) {
                opponent.name = opponentDict[@"username"];
            } else {
                opponent.name = opponentDict[@"name"];
            }

            if (opponentDict[@"id"]) {
                opponent.userID = opponentDict[@"id"];
            }
            if (opponentDict[@"avatar_thumb_url"] &&
                ![opponentDict[@"avatar_thumb_url"] isEqual:[NSNull null]]) {
                NSString *url =
                    [QZBServerBaseUrl stringByAppendingString:opponentDict[@"avatar_thumb_url"]];

                opponent.imageURL = [NSURL URLWithString:url];
            } else {
                opponent.imageURL = nil;
            }

        } else {
            self.userBeginingScore = [opponentDict[@"points"] integerValue];
            
            if(![opponentDict[@"multiplier"] isEqual:[NSNull null]]) {
                self.userMultiplier = [opponentDict[@"multiplier"] integerValue];
            } else {
                self.userMultiplier = 1;
            }

            if (![hostDict[@"username"] isEqual:[NSNull null]] && hostDict[@"username"]) {
                opponent.name = hostDict[@"username"];
            } else {
                opponent.name = hostDict[@"name"];
            }

            opponent.userID = hostDict[@"id"];
            if (hostDict[@"avatar_thumb_url"] && ![hostDict[@"avatar_thumb_url"] isEqual:[NSNull null]]) {
                NSString *url = [QZBServerBaseUrl stringByAppendingString:hostDict[@"avatar_thumb_url"]];
                opponent.imageURL = [NSURL URLWithString:url];
            } else {
                opponent.imageURL = nil;
            }
        }
            
           // self.firstUser = [[QZBUserInSession alloc] initWithUser:user1];
            self.opponentUser = [[QZBUserInSession alloc] initWithUser:opponent];
        }

        //  self.questions = questions;
        //   self.opponentUser = [[QZBUserInSession alloc] initWithUser:opponent];

        self.questions = questions;
        self.firstUser = [[QZBUserInSession alloc] initWithUser:user1];
       // self.opponentUser = [[QZBUserInSession alloc] initWithUser:opponent];
        self.currentQestion = 0;
    }
    return self;  //[self initWithQestions:questions first:user1 opponentUser:opponent];
}

#pragma mark - parsers
//
//-(NSArray *)parseArraOfQuest:(NSArray *)arrayOfQuestionDicts{
//    NSMutableArray *questions = [NSMutableArray array];
//    
//    for (NSDictionary *d in arrayOfQuestionDicts) {
//        QZBQuestion *question = [[QZBQuestion alloc] initWithDictionary:d];
//        
//        [questions addObject:question];
//    }
//
//    
//    
//    
//}

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


-(NSUInteger)scoreForQestion:(QZBQuestion *)qestion
                       answer:(QZBAnswer *)answer {
    
    
    BOOL isRight = [self isAnswerRightForQestion:qestion answer:answer];
    BOOL isLast = NO;
    
    if ([self.questions indexOfObject:qestion] == ([self.questions count] - 1) && !self.isRoom) {
        isLast = YES;
    }
    
    NSUInteger score = [self scoreIsRightAnswer:isRight isLast:isLast answerTime:answer];
    
    return score;
}

-(QZBQuestion *)questionWithID:(NSInteger)questionID {

    
    
    for(QZBQuestion *q in self.questions){
        
        if(q.questionId == questionID){
            return q;
        }
    }
    return nil;
}


//вызывается при ответе пользователем на вопрос
- (void)gaveAnswerByUser:(QZBUserInSession *)user
              forQestion:(QZBQuestion *)qestion
                  answer:(QZBAnswer *)answer {
    BOOL isRight = [self isAnswerRightForQestion:qestion answer:answer];
    BOOL isLast = NO;

    if ([self.questions indexOfObject:qestion] == ([self.questions count] - 1) && !self.isRoom) {
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
