#import <Foundation/Foundation.h>

#import "QZBSession.h"
#import "QZBOpponentBot.h"
#import "QZBServerManager.h"

UIKIT_EXTERN NSString *const QZBOneOfUserInRoomGaveAnswer;//test

@class QZBOnlineSessionWorker;
@class QZBRoomWorker;

@interface QZBSessionManager : NSObject

@property (assign, nonatomic, readonly) BOOL isGoing;
@property (assign, nonatomic, readonly) BOOL isChallenge;
@property (assign, nonatomic, readonly) BOOL isOfflineChallenge;
@property (assign, nonatomic, readonly) BOOL isRoom;

@property (strong, nonatomic, readonly) NSString *sessionResult;
@property (assign, nonatomic, readonly) NSInteger multiplier;
@property (strong, nonatomic, readonly) QZBGameTopic *topic;

@property (strong, nonatomic, readonly) QZBQuestion *currentQuestion;
@property (assign, nonatomic, readonly) NSUInteger currentTime;

@property (assign, nonatomic, readonly) NSUInteger firstUserScore;
@property (assign, nonatomic, readonly) NSUInteger secondUserScore;

@property (assign, nonatomic, readonly) NSInteger userBeginingScore;

@property (copy, nonatomic, readonly) NSString *firstUserName;
@property (copy, nonatomic, readonly) NSString *opponentUserName;

@property (strong, nonatomic, readonly) id <QZBUserProtocol> opponent;

@property (strong, nonatomic, readonly) NSURL *firstImageURL;
@property (strong, nonatomic, readonly) NSURL *opponentImageURL;

@property (assign, nonatomic, readonly) NSUInteger roundNumber;
@property (assign, nonatomic, readonly) BOOL isDoubled;
@property (assign, nonatomic, readonly) BOOL didFirstUserAnswered;
@property (assign, nonatomic, readonly) NSUInteger sessionTime;

@property (assign, nonatomic, readonly) QZBQuestionWithUserAnswer *firstUserLastAnswer;
@property (assign, nonatomic, readonly) QZBQuestionWithUserAnswer *opponentUserLastAnswer;
@property (strong, nonatomic, readonly) NSMutableArray *askedQuestions;  // QZBQuestion

//room
@property (strong, nonatomic, readonly) QZBRoomWorker *roomWorker;

- (void)setSession:(QZBSession *)session;

- (void)setBot:(QZBOpponentBot *)bot;

- (void)setOnlineSessionWorkerFromOutside:(QZBOnlineSessionWorker *)onlineSessionWorker;

- (void)setTopicForSession:(QZBGameTopic *)topic;

- (void)setIsChallenge:(BOOL)isChallenge;

+ (instancetype)sessionManager;

- (void)newQuestionStart;

- (void)firstUserAnswerCurrentQuestinWithAnswerNumber:(NSUInteger)answerNum;

- (void)opponentUserAnswerCurrentQuestinWithAnswerNumber:(NSUInteger)answerNum;

- (void)opponentUserAnswerCurrentQuestinWithAnswerNumber:(NSUInteger)answerNum
                                                    time:(NSUInteger)time;

- (NSNumber *)sessionID;

- (NSArray *)sessionQuestions;

- (void)removeBotOrOnlineWorker;

- (void)makeSessionRoomSession;

- (void)closeSession;

#pragma mark - online methods

- (QZBQuestion *)findQZBQuestionWithID:(NSInteger)questionID;

- (void)opponentAnswerNotInTimeQuestion:(QZBQuestion *)question
                           AnswerNumber:(NSUInteger)answerNum
                                   time:(NSUInteger)time;

#pragma mark - rooms

- (void)setRoomWorkerToSessionWorker:(QZBRoomWorker *)roomWorker;

- (void)oneOfOpponentWithID:(NSNumber *)userID
     answeredQuestionWithID:(NSNumber *)questionID
                   answerID:(NSNumber *)answerID
                   withTime:(NSNumber *)time;

@end
