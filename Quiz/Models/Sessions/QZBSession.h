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

@property (nonatomic, strong, readonly) NSArray *questions;  // QZBQuestion
@property (nonatomic, strong, readonly) QZBUserInSession *firstUser;
@property (nonatomic, strong, readonly) QZBUserInSession *opponentUser;
@property (strong, nonatomic, readonly) NSNumber *lobbyID;
@property (assign, nonatomic, readonly) NSInteger session_id;
@property (assign, nonatomic, readonly) NSInteger userBeginingScore;
@property (copy, nonatomic, readonly) NSString *fact;


@property (assign, nonatomic, readonly) NSInteger userMultiplier;

@property (assign, nonatomic, readonly) BOOL isRoom;

//- (instancetype)initWithQestions:(NSArray *)qestions
//                           first:(id<QZBUserProtocol> )firstUser
//                    opponentUser:(id<QZBUserProtocol> )opponentUser;

- (instancetype)initWIthDictionary:(NSDictionary *)dict;

- (void)gaveAnswerByUser:(QZBUserInSession *)user forQestion:(QZBQuestion *)qestion answer:(QZBAnswer *)answer;


- (QZBWinnew)getWinner;

//for rooms
-(NSUInteger)scoreForQestion:(QZBQuestion *)qestion
                      answer:(QZBAnswer *)answer;//for rooms
-(QZBQuestion *)questionWithID:(NSInteger)questionID;

@end
