//
//  QZBSessionManager.m
//  QZBQuizBattle
#import "QZBSessionManager.h"
#import "QZBUser.h"
#import "QZBOnlineSessionWorker.h"
#import "QZBRoomWorker.h"
#import "QZBRoom.h"
#import <Crashlytics/Crashlytics.h>
#import <DDLog.h>
static const int ddLogLevel = LOG_LEVEL_VERBOSE;

NSString *const QZBOneOfUserInRoomGaveAnswer = @"oneOfUserInRoomGaveAnswer";

@interface QZBSessionManager ()

@property (assign, nonatomic) BOOL isGoing;
@property (assign, nonatomic) BOOL isOfflineChallenge;
@property(assign, nonatomic) BOOL isChallenge;
@property (assign, nonatomic) BOOL isFinished;
//если пользователель нажал играть оффлайн когда бросил вызов


@property(strong, nonatomic) id<QZBUserProtocol>opponent;

@property(assign, nonatomic) NSInteger multiplier;

@property(strong, nonatomic) NSString *sessionResult;

@property (strong, nonatomic) QZBSession *gameSession;
@property (strong, nonatomic) QZBQuestion *currentQuestion;
@property (assign, nonatomic) NSUInteger roundNumber;
@property (assign, nonatomic) BOOL isDoubled;

@property (strong, nonatomic) QZBGameTopic *topic;

@property(assign, nonatomic) NSInteger userBeginingScore;

@property (copy, nonatomic) NSString *firstUserName;
@property (copy, nonatomic) NSString *opponentUserName;

@property (strong, nonatomic) NSURL *firstImageURL;
@property (strong, nonatomic) NSURL *opponentImageURL;

@property (strong, nonatomic) NSDate *startTime;
@property (strong, nonatomic) NSTimer *questionTimer;
@property (assign, nonatomic) NSUInteger currentTime;

@property (assign, nonatomic) NSUInteger firstUserScore;
@property (assign, nonatomic) NSUInteger secondUserScore;

@property (assign, nonatomic) BOOL didFirstUserAnswered;
@property (assign, nonatomic) BOOL didOpponentUserAnswered;

@property (assign, nonatomic) QZBQuestionWithUserAnswer *firstUserLastAnswer;
@property (assign, nonatomic) QZBQuestionWithUserAnswer *opponentUserLastAnswer;

@property (strong, nonatomic) NSMutableArray *askedQuestions;  // QZBQuestion

@property (strong, nonatomic) QZBOpponentBot *bot;
@property (strong, nonatomic) QZBOnlineSessionWorker *onlineSessionWorker;

@property (assign, nonatomic) BOOL sessionSetted;


//@property(assign, nonatomic) BOOL isRoom;
@property (strong, nonatomic) QZBRoomWorker *roomWorker;


@end

@implementation QZBSessionManager

- (instancetype)init {
    self = [super init];
    if (self) {
        DDLogInfo(@"init");
        _sessionTime = 100;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //[super dealloc];
}

+ (instancetype)sessionManager {
    static id sharedInstance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}

- (void)setSession:(QZBSession *)session {
    if (_gameSession) {
        return;
    }
    
    CLS_LOG(@"sessionid %ld, lobbbyid %@",(long)session.session_id, session.lobbyID);
    
    self.isFinished = NO;
    self.isGoing = YES;
    _gameSession = session;
    self.multiplier = session.userMultiplier;
    
    self.userBeginingScore = session.userBeginingScore;
    
    self.currentQuestion = [session.questions firstObject];

    self.firstImageURL = session.firstUser.user.imageURL;
    self.opponentImageURL = session.opponentUser.user.imageURL;

    // TODO timer invalidate

    self.firstUserLastAnswer = nil;
    self.opponentUserLastAnswer = nil;

    self.firstUserScore = 0;
    self.secondUserScore = 0;
    self.didFirstUserAnswered = NO;
    self.didOpponentUserAnswered = NO;
    self.questionTimer = nil;
    self.roundNumber = 1;
    self.isDoubled = NO;
    self.askedQuestions = [NSMutableArray array];
    
    self.sessionResult = nil;

    self.sessionSetted = YES;

    self.firstUserName = session.firstUser.user.name;
    self.opponentUserName = session.opponentUser.user.name;
    
    self.opponent = session.opponentUser.user;
    
    //self.isRoom = session.isRoom;
}

-(void)setIsChallenge:(BOOL)isChallenge{
    _isChallenge =  isChallenge;
}

-(void)setTopicForSession:(QZBGameTopic *)topic{
    self.topic = topic;
}

- (void)setBot:(QZBOpponentBot *)bot {
    if (_bot && _onlineSessionWorker) {
        return;
    } else {
        self.isOfflineChallenge = NO;
        _bot = bot;
    }
}

//room
- (void)setRoomWorkerToSessionWorker:(QZBRoomWorker *)roomWorker {
    self.roomWorker = roomWorker;
    
    if (self.onlineSessionWorker) {
        [self.onlineSessionWorker closeConnection];
        
    }
    self.bot = nil;
    
    self.isOfflineChallenge = YES;
    
}

-(BOOL)isRoom{
    if(self.roomWorker){
        return YES;
    }else {
        return NO;
    }
}
//

- (NSNumber *)sessionID {
    if(self.gameSession){
        return @(self.gameSession.session_id);
    } else {
        return nil;
    }
}

-(NSArray *)sessionQuestions {
    
    return self.gameSession.questions;
}

- (void)setOnlineSessionWorkerFromOutside:(QZBOnlineSessionWorker *)onlineSessionWorker {
    if (_onlineSessionWorker && _bot) {
        return;
    } else {
        self.isOfflineChallenge = NO;
        _onlineSessionWorker = onlineSessionWorker;
    }
}

- (void)removeBotOrOnlineWorker {
    self.bot = nil;

    if (self.onlineSessionWorker) {
        [self.onlineSessionWorker closeConnection];
    }
    
    [[QZBServerManager sharedManager] PATCHMakeChallengeOfflineWithNumber:@(self.gameSession.session_id)
                                                                onSuccess:^{
        
       DDLogInfo(@"PATCHED");
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
    }];
    
    self.onlineSessionWorker = nil;
    self.isOfflineChallenge = YES;
}

- (void)makeSessionRoomSession {
    self.bot = nil;
    
    if (self.onlineSessionWorker) {
        [self.onlineSessionWorker closeConnection];
    }
    self.onlineSessionWorker = nil;
    self.isOfflineChallenge = YES;
}



- (void)timeCountingStart {
    if (!self.questionTimer) {
        self.questionTimer = [NSTimer scheduledTimerWithTimeInterval:0.1  
                                                              target:self
                                                            selector:@selector(updateTime:)
                                                            userInfo:nil
                                                             repeats:YES];

        DDLogInfo(@"new timer alloc");
    }
}

- (void)updateTime:(NSTimer *)timer {
    if (self.questionTimer && [timer isEqual:self.questionTimer]) {
        self.currentTime++;

    } else {
        DDLogWarn(@"bad timer invalidate");
        [timer invalidate];
        timer = nil;
    }
    if (self.currentTime < 100) {

    } else {
        if (self.questionTimer) {
            [self.questionTimer invalidate];
            self.questionTimer = nil;
            [self postNotificationNeedUnshow];
        } else {
            DDLogWarn(@"session timer problem");
            [timer invalidate];
            timer = nil;
        }
    }
}

// TODO: count answerTime
//вызывается для запуска таймера игровой сессии
- (void)newQuestionStart {
    // self.answered = NO;
    self.currentTime = 0;
    self.didFirstUserAnswered = NO;
    self.didOpponentUserAnswered = NO;

    [self timeCountingStart];

    if (self.bot) {
        DDLogInfo(@"new questionStarted");
        NSUInteger questNum = [self.gameSession.questions indexOfObject:self.currentQuestion];

        NSNumber *questionNumber = [NSNumber numberWithUnsignedInteger:questNum];

        [[NSNotificationCenter defaultCenter]
            postNotificationName:@"QZBNewQuestionTimeCountingStart"
                          object:questionNumber];
    }
}

#pragma mark - users answes questions

//главный метод для первого пользователя
- (void)firstUserAnswerCurrentQuestinWithAnswerNumber:(NSUInteger)answerNum {
    if (self.didFirstUserAnswered) {
        return;
    }

    DDLogVerbose(@"%ld", (long)self.currentTime / 10);
    self.didFirstUserAnswered = YES;
    [self firstUserAnswerCurrentQuestinWithAnswerNumber:answerNum time:self.currentTime / 10];
}

//главный метод для второго пользователя
- (void)opponentUserAnswerCurrentQuestinWithAnswerNumber:(NSUInteger)answerNum {

    DDLogInfo(@"%ld", (long)self.currentTime / 10);
    [self opponentUserAnswerCurrentQuestinWithAnswerNumber:answerNum time:self.currentTime / 10];
}

//метод для подсчета очков первого пользователя
- (void)firstUserAnswerCurrentQuestinWithAnswerNumber:(NSUInteger)answerNum time:(NSUInteger)time {
    //отправляет данные о ходе пользователя
    if(!self.roomWorker){
    [[QZBServerManager sharedManager] PATCHSessionQuestionWithID:self.currentQuestion.questionId
                                                          answer:answerNum
                                                            time:time
                                                       onSuccess:nil
                                                       onFailure:nil];
    } else {
        
        [[QZBServerManager sharedManager]
         POSTAnswerRoomQuestionWithID:self.currentQuestion.questionId
         answerID:answerNum
         time:time
         onSuccess:nil
         onFailure:nil];
    }

    [self someAnswerCurrentQuestinUser:self.gameSession.firstUser AnswerNumber:answerNum time:time];

    self.firstUserScore = self.gameSession.firstUser.currentScore;

    self.firstUserLastAnswer = [self.gameSession.firstUser.userAnswers lastObject];

    [self checkNeedUnshow];

    if (!self.bot && !self.onlineSessionWorker) {  //если пользователь играет оффлайн сам с собой
        [self opponentUserAnswerCurrentQuestinWithAnswerNumber:0];
    }
}

// метод для подсчета очков второго пользователя
- (void)opponentUserAnswerCurrentQuestinWithAnswerNumber:(NSUInteger)answerNum
                                                    time:(NSUInteger)time {
    if (self.didOpponentUserAnswered) {
        return;
    }
    self.didOpponentUserAnswered = YES;

    [self someAnswerCurrentQuestinUser:self.gameSession.opponentUser
                          AnswerNumber:answerNum
                                  time:time];

    self.secondUserScore = self.gameSession.opponentUser.currentScore;
    self.opponentUserLastAnswer = [self.gameSession.opponentUser.userAnswers lastObject];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"QZBOpponentUserMadeChoose"
                                                        object:self];
    [self checkNeedUnshow];
}
//rooms

- (void)oneOfOpponentWithID:(NSNumber *)userID
     answeredQuestionWithID:(NSNumber *)questionID
                   answerID:(NSNumber *)answerID
                   withTime:(NSNumber *)time {
    
    if(self.roomWorker){
        
        QZBQuestion *question = [self.gameSession questionWithID:questionID.integerValue];
        
        QZBAnswer *answer = [[QZBAnswer alloc] initWithAnswerNumber:answerID.integerValue
                                                         answerTime:time.integerValue];
        
        NSInteger points = 0;
        
        if(question){
            points = [self.gameSession scoreForQestion:question answer:answer];
        }
        
        
        [self.roomWorker userWithId:userID reachedPoints:@(points)];
        
        
        NSMutableDictionary *payload = [@{@"userID":userID,
                                         @"correct":@(NO)} mutableCopy];
        if(points > 0){
            payload[@"correct"] = @(YES);
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:QZBOneOfUserInRoomGaveAnswer
                                                            object:[NSDictionary dictionaryWithDictionary:payload]];

    }    
}
//- (void)oneOfOpponentWithID:(NSNumber *)userID
//     answeredQuestionWithID:(NSNumber *)questionID
//                   withTime:(NSNumber *)time {
//    
//    
//    
//    if(self.roomWorker){
//        [self.roomWorker userWithId:userID reachedPoints:@(10)];
//    }
//    
//}

//для подсчета очков в сессии для первого или второо
- (void)someAnswerCurrentQuestinUser:(QZBUserInSession *)user
                        AnswerNumber:(NSUInteger)answerNum
                                time:(NSUInteger)time {
    QZBAnswer *answer = [[QZBAnswer alloc] initWithAnswerNumber:answerNum answerTime:time];

    [self.gameSession gaveAnswerByUser:user forQestion:self.currentQuestion answer:answer];
}

- (void)checkNeedUnshow {
    if (self.didFirstUserAnswered && self.didOpponentUserAnswered) {
        if (self.questionTimer != nil) {
            [self.questionTimer invalidate];
            self.questionTimer = nil;
        }
        [self postNotificationNeedUnshow];
    }
}

// answering question after end question

//-(void)opponentUserAnswerPreviousQuestWithID:

#pragma mark - post notifications

- (void)postNotificationNeedUnshow {
    NSUInteger index = [self.gameSession.questions indexOfObject:self.currentQuestion];
    if (!self.didFirstUserAnswered) {
        [self.gameSession gaveAnswerByUser:self.gameSession.firstUser
                                forQestion:self.currentQuestion
                                    answer:nil];
    }

    if (!self.didOpponentUserAnswered) {
        [self.gameSession gaveAnswerByUser:self.gameSession.opponentUser
                                forQestion:self.currentQuestion
                                    answer:nil];
    }

    self.didFirstUserAnswered = YES;
    self.didOpponentUserAnswered = YES;
    //чтобы нельзя было ответить пока переключаются вопросы

    self.firstUserLastAnswer = [self.gameSession.firstUser.userAnswers lastObject];

    self.opponentUserLastAnswer = [self.gameSession.opponentUser.userAnswers lastObject];

    self.roundNumber = index + 2;
    if(self.currentQuestion){//TEST

    [self.askedQuestions addObject:self.currentQuestion];
    }
    //добавляет уже заданый вопрос в список заданых вопросов

    if (index < [self.gameSession.questions count] - 1) {
        index++;
        
        if(!self.isRoom && index == [self.gameSession.questions count] - 1){
            self.isDoubled = YES;
        } else {
            self.isDoubled = NO;
        }
        
        
        self.currentQuestion = [self.gameSession.questions objectAtIndex:index];

        [[NSNotificationCenter defaultCenter] postNotificationName:@"QZBNeedUnshowQuestion"
                                                            object:self];

    } else {
        [self postNotificationWithGameResult];

        // [self closeSession];
    }
}

- (void)postNotificationWithGameResult {
    QZBWinnew winner = [self.gameSession getWinner];

    NSString *resultOfGame = @"";

    switch (winner) {
        case QZBWinnerFirst:
            resultOfGame = @"Победа";
            break;
        case QZBWinnerOpponent:
            resultOfGame = @"Поражение";
            break;

        case QZBWinnerNone:
            resultOfGame = @"Ничья";
            break;
        default:
            resultOfGame = @"Проблемы";  //исправить
            break;
    }
    
    

    self.sessionResult = resultOfGame;
    self.isFinished = YES;
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"QZBNeedFinishSession"
                                                        object:resultOfGame];
}

- (void)closeSession {
    
    NSNumber *sessionID = [NSNumber numberWithInteger:self.gameSession.session_id];
    
    if (!self.isOfflineChallenge && self.isFinished && !self.roomWorker) {
        
        [[QZBServerManager sharedManager] PATCHCloseSessionID:sessionID
                                                    onSuccess:^{
                                                        //закрывает сессию
                                                        DDLogInfo(@"CLOSED PERFECTLY!!! %@", sessionID);
                                                    }
                                                    onFailure:^(NSError *error, NSInteger statusCode){
                                                        DDLogError(@"didnt closed");
                                                    }];
        if(self.gameSession.lobbyID){
        [[QZBServerManager sharedManager] DELETELobbiesWithID:self.gameSession.lobbyID
                                                    onSuccess:^{
            //@""
                                                        
                                                        
        } onFailure:^(NSError *error, NSInteger statusCode) {
            
        }];
        }
    }
    
    
    self.isFinished = NO;
    self.isOfflineChallenge = NO;
    self.multiplier = 1;
    
    [self.questionTimer invalidate];
    self.questionTimer = nil;
    self.sessionResult = nil;
    
    self.topic = nil;

    self.isGoing = NO;
    self.isChallenge = NO;
    self.gameSession = nil;
    self.bot = nil;
    self.opponent = nil;
    self.askedQuestions = nil;
    if (self.onlineSessionWorker) {
        [self.onlineSessionWorker closeConnection];
    }
    
    
    self.onlineSessionWorker = nil;
    
    if(self.roomWorker){
        
//        [[QZBServerManager sharedManager] POSTFinishRoomSessionWithID:self.roomWorker.room.roomID
//                                                            onSuccess:nil onFailure:nil];
        //[self.roomWorker closeOnlineWorker];
        self.roomWorker = nil;
    }
    
    self.sessionSetted = NO;
}

#pragma mark - online methods

- (QZBQuestion *)findQZBQuestionWithID:(NSInteger)questionID {
    for (QZBQuestion *quest in self.askedQuestions) {
        if (quest.questionId == questionID) {
            return quest;
        }
    }
    return nil;
}

- (void)opponentAnswerNotInTimeQuestion:(QZBQuestion *)question
                           AnswerNumber:(NSUInteger)answerNum
                                   time:(NSUInteger)time {
    BOOL couldAnswer = [self.gameSession.opponentUser couldAnswerAfterTime:question];

    DDLogInfo(couldAnswer ? @"Yes" : @"No");

    if (couldAnswer) {
        QZBAnswer *answer = [[QZBAnswer alloc] initWithAnswerNumber:answerNum answerTime:time];

        QZBQuestionWithUserAnswer *qanda =
            [self.gameSession.opponentUser findQuestionAndAnswerWithQuestion:question];

        [self.gameSession.opponentUser.userAnswers removeObject:qanda];

        [self.gameSession gaveAnswerByUser:self.gameSession.opponentUser
                                forQestion:question
                                    answer:answer];
        self.opponentUserLastAnswer = [self.gameSession.opponentUser.userAnswers lastObject];
        self.secondUserScore = self.gameSession.opponentUser.currentScore;
    }
}

//- (NSNumber *)pointsForQuestionWithID:(NSNumber *)questionID answerNum:(NSNumber *)answerID {
//    for (QZBQuestion *quest in self.gameSession.questions){
//        if()
//    }
//}

@end
