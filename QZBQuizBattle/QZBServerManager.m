//
//  QZBServerManager.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 24/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import "QZBServerManager.h"
//#import <CocoaLumberjack/CocoaLumberjack.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "QZBGameTopic.h"
#import "QZBLobby.h"
#import "QZBSession.h"
#import "QZBCategory.h"
#import "QZBOpponentBot.h"
#import "QZBOnlineSessionWorker.h"
#import "QZBUser.h"
#import "QZBCurrentUser.h"
#import "QZBAnotherUser.h"
#import "QZBUserInRating.h"
#import "NSString+MD5.h"
#import "CoreData+MagicalRecord.h"
#import "TSMessage.h"

//#import "QZBRequestUser.h"
#import "QZBProduct.h"
#import "QZBChallengeDescription.h"
#import "QZBChallengeDescriptionWithResults.h"
#import "QZBAchievement.h"
#import <SVProgressHUD.h>
#import "AppDelegate.h"
#import "QZBFriendRequest.h"

// image manager
#import <DFImageManager/DFImageManager.h>
#import <DFImageManager/DFImageRequestOptions.h>
#import <DFImageManager/DFURLImageFetcher.h>
#import <DFImageManager/DFImageRequest.h>

// rooms

#import "QZBRoom.h"
#import "QZBRoomSessionResults.h"
#import "QZBRoomInvite.h"

// topics

#import "QZBTopicWorker.h"

#import <DDLog.h>
static const int ddLogLevel = LOG_LEVEL_VERBOSE;

//#import "QZBLoggingConfig.h"

//#ifdef DEBUG
// static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
//#else
// static const DDLogLevel ddLogLevel = DDLogLevelWarning;
//#endif
// static const DDLogLevel ddLogLevel = DDLogLevelWarning;

NSString *const QZBServerBaseUrl = @"http://188.166.14.118";//@"http://quizapp.binaryblitz.ru";
NSString *const QZBNoInternetConnectionMessage =
    @"Проверьте интернет " @"соедин" @"е" @"н" @"и" @"е";

@interface QZBServerManager ()

@property (strong, nonatomic) AFHTTPRequestOperationManager *requestOperationManager;
@property (copy, nonatomic) NSString *baseURL;

@end

@implementation QZBServerManager

+ (QZBServerManager *)sharedManager {
    static QZBServerManager *manager = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[QZBServerManager alloc] init];
    });

    return manager;
}

- (id)init {
    self = [super init];
    if (self) {
        NSString *apiPath = [NSString stringWithFormat:@"%@/%@"/*@"http://quizapp.binaryblitz.ru/%@"*/,QZBServerBaseUrl, @"api"];
        self.baseURL = apiPath;
        //[NSString stringWithFormat:@"http://%@:%@/", @"192.168.1.39", @"3000"];
        NSURL *url = [NSURL URLWithString:apiPath];
        // url.port = @3000;

        self.requestOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    }
    return self;
}

#pragma mark - categories and topics

- (void)GETCategoriesOnSuccess:(void (^)(NSArray *topics))successAF
                     onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *params = @{ @"token" : [QZBCurrentUser sharedInstance].user.api_key };

    [self.requestOperationManager GET:@"categories"
        parameters:params
        success:^(AFHTTPRequestOperation *operation, NSArray *responseObject) {
            DDLogInfo(@"category JSON: %@", responseObject);

            [self updateCategories:responseObject];

            [MagicalRecord saveUsingCurrentThreadContextWithBlock:nil
                                                       completion:^(BOOL success, NSError *error) {
                                                           if (success) {
                                                               if (successAF) {
                                                                   successAF(
                                                                       [QZBCategory MR_findAll]);
                                                               }
                                                           }
                                                       }];

        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DDLogInfo(@"Error: %@", error);

            if (failure) {
                failure(error, operation.response.statusCode);
            }
        }];
}

- (void)GETTopicsWithCategory:(QZBCategory *)category
                    onSuccess:(void (^)(NSArray *topics))successAF
                    onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *params = @{ @"token" : [QZBCurrentUser sharedInstance].user.api_key };

    NSString *urlAsString = [NSString stringWithFormat:@"categories/%@", category.category_id];

    [self.requestOperationManager GET:urlAsString
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            DDLogInfo(@"topic JSON: %@", responseObject);

            [self updateTopcs:(NSDictionary *)responseObject inCategory:category];

            [MagicalRecord saveUsingCurrentThreadContextWithBlock:nil
                                                       completion:^(BOOL success, NSError *error) {

                                                           if (successAF) {
                                                               successAF(nil);
                                                           }

                                                       }];

        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DDLogInfo(@"Error: %@", error);

            if (failure) {
                failure(error, operation.response.statusCode);
            }
        }];
}

- (void)updateCategories:(NSArray *)categoryRequest {
    NSMutableArray *objectsArray = [NSMutableArray array];

    for (NSDictionary *dict in categoryRequest) {
        NSString *name = [dict objectForKey:@"name"];
        id category_id = [dict objectForKey:@"id"];

        NSString *bannerURL = nil;
        NSString *backgroundURL = nil;

        if (![dict[@"banner_url"] isEqual:[NSNull null]] && dict[@"banner_url"]) {
            bannerURL = dict[@"banner_url"];
        }

        if (![dict[@"background_url"] isEqual:[NSNull null]] && dict[@"background_url"]) {
            backgroundURL = dict[@"background_url"];
        }

        QZBCategory *existingEntity =
            [QZBCategory MR_findFirstByAttribute:@"category_id" withValue:category_id];

        if (!existingEntity) {
            existingEntity = [QZBCategory MR_createEntity];
            existingEntity.category_id = category_id;
            existingEntity.name = name;
        }
        if (backgroundURL && ![backgroundURL isEqualToString:existingEntity.background_url]) {
            existingEntity.background_url =
                [QZBServerBaseUrl stringByAppendingString:backgroundURL];

            [self savePictureFromString:existingEntity.background_url];

        }  // TEST

        if (bannerURL && ![bannerURL isEqualToString:existingEntity.banner_url]) {
            existingEntity.banner_url = [QZBServerBaseUrl stringByAppendingString:bannerURL];

            [self savePictureFromString:existingEntity.banner_url];
        }

        [self updateTopcs:dict inCategory:existingEntity];  // TODO!

        [objectsArray addObject:existingEntity];
    }

    NSMutableArray *allCategories = [[QZBCategory MR_findAll] mutableCopy];

    [allCategories removeObjectsInArray:objectsArray];

    if (allCategories) {
        for (QZBCategory *categ in allCategories) {
            [categ MR_deleteEntity];
        }
    }
}

- (void)savePictureFromString:(NSString *)urlAsString {  //это не работает сейчас
    if (urlAsString) {
        NSURL *url = [NSURL URLWithString:urlAsString];
        //        NSURLRequest *imageRequest =
        //            [NSURLRequest requestWithURL:url
        //                             cachePolicy:NSURLRequestReturnCacheDataElseLoad
        //                         timeoutInterval:60];
        //
        //        UIImageView *v = [[UIImageView alloc] init];
        //       // [v setImageWithURLRequest:imageRequest placeholderImage:nil success:nil
        //       failure:nil]; //redo

        DFImageRequestOptions *options = [DFImageRequestOptions new];
        //       // options.allowsClipping = YES;
        options.userInfo = @{ DFURLRequestCachePolicyKey : @(NSURLRequestReturnCacheDataElseLoad) };
        options.expirationAge = 60 * 60 * 24 * 10;
        options.priority = DFImageRequestPriorityLow;

        DFImageRequest *request = [DFImageRequest requestWithResource:url
                                                           targetSize:CGSizeZero
                                                          contentMode:DFImageContentModeAspectFill
                                                              options:options];

        [[DFImageManager sharedManager]
            requestImageForRequest:request
                        completion:^(UIImage *image, NSDictionary *info) {

                            NSLog(@"image info %@", info);
                        }];
    }
}

- (void)updateTopcs:(NSDictionary *)topicsInRequest inCategory:(QZBCategory *)category {
    //[QZBGameTopic MR_truncateAll];  // comment on release version

    NSArray *topics = [topicsInRequest objectForKey:@"topics"];

    NSMutableArray *objectsArray = [NSMutableArray array];

    for (NSDictionary *dict in topics) {
        QZBGameTopic *existingEntity = [QZBTopicWorker parseTopicFromDict:dict inCategory:category];

        [objectsArray addObject:existingEntity];
    }

    NSMutableArray *allTopics =
        [NSMutableArray arrayWithArray:[[category relationToTopic] allObjects]];

    [allTopics removeObjectsInArray:objectsArray];

    if (allTopics) {  //удаляет несуществующие категории
        for (QZBGameTopic *topic in allTopics) {
            [topic MR_deleteEntity];
        }
    }
}

//- (QZBCategory *)tryFindRelatedCategoryToTopic:(QZBGameTopic *)topic {
//    QZBGameTopic *exitedTopic =
//        [QZBGameTopic MR_findFirstByAttribute:@"topic_id" withValue:topic.topic_id];
//    QZBCategory *category = nil;
//
//    if (exitedTopic) {
//        category = exitedTopic.relationToCategory;
//    }
//    return category;
//}

- (void)GETTopicsForMainOnSuccess:(void (^)(NSDictionary *resultDict))success
                        onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    if (![QZBCurrentUser sharedInstance].user.api_key) {
        if (failure) {
            failure(nil, -1);
        }
        return;
    }

    NSDictionary *params = @{ @"token" : [QZBCurrentUser sharedInstance].user.api_key };

    [self.requestOperationManager GET:@"pages/home"
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {

            DDLogInfo(@"main %@", responseObject);

            NSArray *faveTopicsDicts = responseObject[@"favorite_topics"];
            NSArray *friendsFaveTopicsDicts = responseObject[@"friends_favorite_topics"];
            NSArray *featuredTopicsDicts = responseObject[@"featured_topics"];
            NSArray *randomTopicsDicts = responseObject[@"random_topics"];

            NSArray *challengesDicts = responseObject[@"challenges"];
            NSArray *challengedDicts = responseObject[@"challenged"];

            NSArray *roomInvitesDicts = responseObject[@"invites"];
            NSArray *roomsDicts = responseObject[@"random_rooms"];

            NSArray *faveTopics = [self parseTopicsArray:faveTopicsDicts];
            NSArray *friendsFaveTopics = [self parseTopicsArray:friendsFaveTopicsDicts];
            NSArray *featuredTopics = [self parseTopicsArray:featuredTopicsDicts];
            NSArray *randomTopics = [self parseTopicsArray:randomTopicsDicts];

            NSArray *challenges = [self parseChallengesFromArray:challengesDicts];
            NSArray *challenged = [self parseChallengeResultsFromArray:challengedDicts];

            NSArray *roomInvites = [self parseRoomInvitesFromArray:roomInvitesDicts];
            NSArray *rooms = [self parseRoomsFromArray:roomsDicts];

            NSDictionary *resultDict = @{
                @"favorite_topics" : faveTopics,
                @"friends_favorite_topics" : friendsFaveTopics,
                @"featured_topics" : featuredTopics,
                @"random_topics" : randomTopics,
                @"challenges" : challenges,
                @"challenged" : challenged,
                @"room_invites" : roomInvites,
                @"rooms" : rooms
            };

            //  NSDictionary *resultDict = @{};
            if (success) {
                success(resultDict);
            }

        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            DDLogInfo(@"%@, /n %@", operation, error);

            if (failure) {
                failure(error, operation.response.statusCode);
            }

        }];
}

- (NSArray *)parseTopicsArray:(NSArray *)topics {
    // AppDelegate *app = [[UIApplication sharedApplication] delegate];

    // id context = app.managedObjectContext;

    NSMutableArray *tmpArr = [NSMutableArray array];
    for (NSDictionary *dict in topics) {
        QZBGameTopic *topic = [QZBTopicWorker parseTopicFromDict:dict];

        [tmpArr addObject:topic];
    }

    NSArray *result = [NSArray arrayWithArray:tmpArr];

    return result;
}

#pragma mark - session methods

- (void)POSTLobbyWithTopic:(QZBGameTopic *)topic
                 onSuccess:(void (^)(QZBLobby *lobby))success
                 onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    //  xxx

    if (!topic.topic_id || ![QZBCurrentUser sharedInstance].user.api_key) {  // TEST its crashes
        if (failure) {
            failure(nil, 0);
        }
        return;
    }

    NSDictionary *params = @{
        @"lobby" : @{@"topic_id" : topic.topic_id},
        @"token" : [QZBCurrentUser sharedInstance].user.api_key
    };

    [self.requestOperationManager POST:@"lobbies"
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            DDLogInfo(@"lobby: %@  ", responseObject);

            QZBLobby *lobby = [[QZBLobby alloc] initWithDict:responseObject];

            if (success) {
                success(lobby);
            }

        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DDLogInfo(@"%@, /n %@", operation, error);

            if (failure) {
                failure(error, operation.response.statusCode);
            }
        }];
}

//?
- (void)GETFindGameWithLobby:(QZBLobby *)lobby
                   onSuccess:(void (^)(QZBSession *session, id bot))success
                   onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *params = @{ @"token" : [QZBCurrentUser sharedInstance].user.api_key };

    NSString *URLString = [NSString stringWithFormat:@"lobbies/%ld/find", (long)lobby.lobbyID];

    DDLogInfo(@"%@", URLString);

    [self.requestOperationManager GET:URLString
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {

            DDLogInfo(@"JSON: %@", responseObject);

            if (responseObject) {
                QZBSession *session = [[QZBSession alloc] initWIthDictionary:responseObject];

                QZBOpponentBot *bot = nil;

                NSNumber *isOffline = responseObject[@"offline"];

                if ([isOffline isEqual:@1]) {
                    bot = [[QZBOpponentBot alloc] initWithDictionary:responseObject];
                }
                if (success) {
                    success(session, bot);
                }
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error){

        }];
}

- (void)PATCHCloseLobby:(QZBLobby *)lobby
              onSuccess:(void (^)(QZBSession *session, id bot))success
              onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *params = @{ @"token" : [QZBCurrentUser sharedInstance].user.api_key };

    NSString *URLString = [NSString stringWithFormat:@"lobbies/%ld/close", (long)lobby.lobbyID];

    DDLogInfo(@"%@", URLString);

    [self.requestOperationManager PATCH:URLString
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            DDLogInfo(@"lobby closed");
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error){

        }];
}

//отправляет данные о ходе пользователя
- (void)PATCHSessionQuestionWithID:(NSInteger)sessionQuestionID
                            answer:(NSInteger)answerID
                              time:(NSInteger)answerTime
                         onSuccess:(void (^)())success
                         onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *params = @{
        @"game_session_question" : @{@"answer_id" : @(answerID), @"time" : @(answerTime)},
        @"token" : [QZBCurrentUser sharedInstance].user.api_key
    };

    NSString *URLString =
        [NSString stringWithFormat:@"game_session_questions/%ld", (long)sessionQuestionID];

    [self.requestOperationManager PATCH:URLString
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {

            DDLogInfo(@"patched");

        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            DDLogInfo(@"room path error%@", error);

        }];
}

- (void)PATCHCloseSessionID:(NSNumber *)sessionID
                  onSuccess:(void (^)())success
                  onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *params = @{ @"token" : [QZBCurrentUser sharedInstance].user.api_key };

    NSString *urlString = [NSString stringWithFormat:@"game_sessions/%@/close", sessionID];

    [self.requestOperationManager PATCH:urlString
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            DDLogInfo(@"session closed");

            if (success) {
                success();
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            if (failure) {
                failure(error, operation.response.statusCode);
            }
            DDLogInfo(@"session close failure %@", error);

        }];
}

- (void)PATCHMakeChallengeOfflineWithNumber:(NSNumber *)sessionID
                                  onSuccess:(void (^)())success
                                  onFailure:
                                      (void (^)(NSError *error, NSInteger statusCode))failure {
    NSString *urlString = [NSString stringWithFormat:@"game_sessions/%@", sessionID];

    NSDictionary *params = @{
        @"token" : [QZBCurrentUser sharedInstance].user.api_key,
        @"game_session" : @{@"offline" : @YES}
    };

    [self.requestOperationManager PATCH:urlString
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            DDLogInfo(@"parched offline");

            if (success) {
                success();
            }

        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DDLogInfo(@"ofline patch error");

            if (failure) {
                failure(error, operation.response.statusCode);
            }

        }];
}

#pragma mark - challenge

// POST /lobbies/challenge
//
// Challenges and notifies opponent. You should open a Pusher channel and wait
// for game-start event
// once the session was returned. You may also receive a challenge-declined
// event if the opponent
// decided to decline your challenge.
//
// opponent_id — opponent
//
// topic_id — topic

- (void)POSTLobbyChallengeWithUserID:(NSNumber *)userID
                             inTopic:(QZBGameTopic *)topic
                           onSuccess:(void (^)(QZBSession *session))success
                           onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    if (!userID) {
        if (failure) {
            failure(nil, -1);
        }
    }

    NSDictionary *params = @{
        @"token" : [QZBCurrentUser sharedInstance].user.api_key,
        @"opponent_id" : userID,
        @"topic_id" : topic.topic_id
    };

    [self.requestOperationManager POST:@"lobbies/challenge"
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {

            DDLogInfo(@"challenge response %@", responseObject);

            QZBSession *session = [[QZBSession alloc] initWIthDictionary:responseObject];

            if (success) {
                success(session);
            }

        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            if (failure) {
                failure(error, operation.response.statusCode);
            }
            DDLogInfo(@" %@", error);
        }];
}

// POST /lobbies/:id/accept_challenge
//
// Accepts the challenge and notifies the host about it. The host player will be
// notified with
// game-start event.

- (void)POSTAcceptChallengeWhithLobbyID:(NSNumber *)lobbyID
                              onSuccess:(void (^)(QZBSession *session, id bot))success
                              onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *params = @{ @"token" : [QZBCurrentUser sharedInstance].user.api_key };
    NSString *urlString = [NSString stringWithFormat:@"lobbies/%@/accept_challenge", lobbyID];

    [self.requestOperationManager POST:urlString
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {

            DDLogInfo(@"accept challenge %@", responseObject);

            QZBSession *session = [[QZBSession alloc] initWIthDictionary:responseObject];
            QZBOpponentBot *opponentBot =
                [[QZBOpponentBot alloc] initWithHostAnswers:responseObject];

            if (success) {
                success(session, opponentBot);
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error){
        }];
}

- (void)POSTDeclineChallengeWhithLobbyID:(NSNumber *)lobbyID
                               onSuccess:(void (^)())success
                               onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *params = @{ @"token" : [QZBCurrentUser sharedInstance].user.api_key };
    NSString *urlString = [NSString stringWithFormat:@"lobbies/%@/decline_challenge", lobbyID];

    [self.requestOperationManager POST:urlString
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {

            if (success) {
                success();
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error){
        }];
}

- (void)GETThrownChallengesOnSuccess:(void (^)(NSArray *challenges))success
                           onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *params = @{ @"token" : [QZBCurrentUser sharedInstance].user.api_key };

    [self.requestOperationManager GET:@"lobbies/challenges"
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            DDLogInfo(@"challenges response %@", responseObject);

            NSArray *challengeDescriptions = [self parseChallengesFromArray:responseObject];

            if (success) {
                success(challengeDescriptions);
            }

        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (failure) {
                failure(error, operation.response.statusCode);
            }
            DDLogInfo(@"%@", error);
        }];
}

- (void)DELETELobbiesWithID:(NSNumber *)lobbyID
                  onSuccess:(void (^)())success
                  onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *params = @{ @"token" : [QZBCurrentUser sharedInstance].user.api_key };

    NSString *urlAsString = [NSString stringWithFormat:@"lobbies/%@", lobbyID];

    [self.requestOperationManager DELETE:urlAsString
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {

            if (success) {
                success();
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            if (failure) {
                failure(error, operation.response.statusCode);
            }
            DDLogInfo(@"%@", error);
        }];
}

- (NSArray *)parseChallengesFromArray:(NSArray *)responseObject {
    NSMutableArray *challengeDescriptionsMuttable = [NSMutableArray array];

    for (NSDictionary *dict in responseObject) {
        QZBChallengeDescription *challengeDescription =
            [[QZBChallengeDescription alloc] initWithDictionary:dict];
        [challengeDescriptionsMuttable addObject:challengeDescription];
    }

    NSArray *challengeDescriptions = [NSArray arrayWithArray:challengeDescriptionsMuttable];

    return challengeDescriptions;
}

- (NSArray *)parseChallengeResultsFromArray:(NSArray *)responseObject {
    NSMutableArray *challengesResultsMuttable = [NSMutableArray array];

    for (NSDictionary *dict in responseObject) {
        if (![dict[@"results"] isEqual:[NSNull null]] && dict[@"results"]) {
            QZBChallengeDescriptionWithResults *result =
                [[QZBChallengeDescriptionWithResults alloc] initWithDictionary:dict];

            [challengesResultsMuttable addObject:result];
        }
    }
    return [NSArray arrayWithArray:challengesResultsMuttable];
}

- (NSArray *)parseRoomInvitesFromArray:(NSArray *)responseObject {
    NSMutableArray *invitesMutable = [NSMutableArray array];
    for (NSDictionary *dict in responseObject) {
        QZBRoomInvite *roomInvite = [[QZBRoomInvite alloc] initWithDictionary:dict];

        [invitesMutable addObject:roomInvite];
    }
    return [NSArray arrayWithArray:invitesMutable];
}

#pragma mark - user registration

- (NSString *)hashPassword:(NSString *)password {
    return password;
}

- (void)POSTRegistrationUser:(NSString *)userName
                       email:(NSString *)userEmail
                    password:(NSString *)password
                   onSuccess:(void (^)(QZBUser *user))success
                   onFailure:(void (^)(NSError *error,
                                       NSInteger statusCode,
                                       QZBUserRegistrationProblem problem))failure {
    NSString *hashedPassword = [self hashPassword:password];

    NSDictionary *params = nil;
    if (userEmail.length > 0) {
        params = @{
            @"player" : @{
                @"username" : userName,
                @"email" : userEmail,
                @"password" : hashedPassword
            }
        };
    } else {
        params = @{
            @"player" : @{ @"username" : userName, @"password" : hashedPassword}
        };
    }

    [self.requestOperationManager POST:@"players"
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            DDLogInfo(@"user registration %@", responseObject);

            QZBUser *user = [[QZBUser alloc] initWithDict:responseObject];

            if (success) {
                success(user);
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            QZBUserRegistrationProblem problem = QZBNoProblems;

            DDLogInfo(@"%@\n responseObject %@", error, operation.responseObject);

            if (![operation.responseObject[@"username"] isEqual:[NSNull null]] &&
                operation.responseObject[@"username"]) {
                NSArray *usernameProblems = operation.responseObject[@"username"];
                // NSString *problem = [usernameProblems firstObject];
                DDLogInfo(@"problem %@", usernameProblems);
                problem = QZBUserNameProblem;
            } else if (![operation.responseObject[@"email"] isEqual:[NSNull null]] &&
                       operation.responseObject[@"email"]) {
                NSArray *usernameProblems = operation.responseObject[@"email"];
                // NSString *problem = [usernameProblems firstObject];
                DDLogInfo(@"problem %@", usernameProblems);
                problem = QZBEmailProblem;
            }

            if (failure) {
                failure(error, operation.response.statusCode, problem);
            }

        }];
}

- (void)POSTLoginUserName:(NSString *)username
                 password:(NSString *)password
                onSuccess:(void (^)(QZBUser *user))success
                onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    NSString *hashedPassword = [self hashPassword:password];

    NSDictionary *params = @{ @"username" : username, @"password" : hashedPassword };

    [self.requestOperationManager POST:@"players/authenticate"
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {

            DDLogInfo(@"login %@", responseObject);

            if (![responseObject objectForKey:@"error"]) {
                QZBUser *user = [[QZBUser alloc] initWithDict:responseObject];

                if (success) {
                    success(user);
                }
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            DDLogInfo(@"%@\n responseObject %@", error, operation.responseObject);
            if (failure) {
                failure(error, operation.response.statusCode);
            }

        }];
}

- (void)POSTAuthWithVKToken:(NSString *)token
                  onSuccess:(void (^)(QZBUser *user))success
                  onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *params = @{ @"token" : token };

    [self.requestOperationManager POST:@"players/authenticate_vk"
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {

            if (![responseObject objectForKey:@"error"]) {
                QZBUser *user = [[QZBUser alloc] initWithDict:responseObject];
                DDLogInfo(@"user response object %@", responseObject);

                if (success) {
                    success(user);
                }
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            if (failure) {
                failure(error, operation.response.statusCode);
            }

            DDLogInfo(@"vk token failure %@  %@", error, operation.responseObject);

        }];
}

- (void)GETPlayerWithID:(NSNumber *)playerID
              onSuccess:(void (^)(QZBAnotherUser *anotherUser))success
              onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *params = @{ @"token" : [QZBCurrentUser sharedInstance].user.api_key };

    NSString *urlString = [NSString stringWithFormat:@"players/%@", playerID];

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.requestOperationManager GET:urlString
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            DDLogInfo(@"user JSON : %@", responseObject);
            QZBAnotherUser *user = [[QZBAnotherUser alloc] initWithDictionary:responseObject];
            BOOL isFriend = [responseObject[@"is_friend"] boolValue];
            user.isFriend = isFriend;

            NSArray *topics = responseObject[@"favorite_topics"];

            user.faveTopics = [self parseTopicsArray:topics];

            user.achievements = [self parseAchievementsFromArray:responseObject[@"achievements"]];

            if (success) {
                success(user);
            }

        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            if (failure) {
                failure(error, operation.response.statusCode);
            }

            DDLogInfo(@"user fail");
        }];
}

- (void)POSTPasswordResetWithEmail:(NSString *)userEmail
                         onSuccess:(void (^)())success
                         onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *params = @{ @"email" : userEmail };

    NSURL *url = [NSURL URLWithString:QZBServerBaseUrl];

    [[[AFHTTPRequestOperationManager alloc] initWithBaseURL:url] POST:@"password_resets"
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {

            if (success) {
                success();
            }

        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            DDLogInfo(@"renew errr %@  response %@", error, operation.responseObject);

            if (operation.response.statusCode == 200) {
                if (success) {
                    success();
                }
            } else {
                if (failure) {
                    failure(error, operation.response.statusCode);
                }
            }

        }];
}

#pragma mark - user change

- (void)PATCHPlayerWithNewPassword:(NSString *)password
                         onSuccess:(void (^)())success
                         onFailure:(void (^)(NSError *error,
                                             NSInteger statusCode,
                                             QZBUserRegistrationProblem problem))failure {
    NSString *hashedPassword = [self hashPassword:password];
    NSDictionary *params = @{
        @"token" : [QZBCurrentUser sharedInstance].user.api_key,
        @"player" : @{@"password" : hashedPassword}
    };

    [self PATHPlayerDataWithDict:params userID:nil onSuccess:success onFailure:failure];
}

- (void)PATCHPlayerWithNewUserName:(NSString *)userName
                         onSuccess:(void (^)())success
                         onFailure:(void (^)(NSError *error,
                                             NSInteger statusCode,
                                             QZBUserRegistrationProblem problem))failure {
    NSDictionary *params = @{
        @"token" : [QZBCurrentUser sharedInstance].user.api_key,
        @"player" : @{@"username" : userName}
    };

    [self PATHPlayerDataWithDict:params userID:nil onSuccess:success onFailure:failure];
}

- (void)PATCHPlayerWithNewUserNameThenRegistration:(NSString *)userName
                                              user:(QZBUser *)user
                                         onSuccess:(void (^)())success
                                         onFailure:
                                             (void (^)(NSError *error,
                                                       NSInteger statusCode,
                                                       QZBUserRegistrationProblem problem))failure {
    NSDictionary *params = @{ @"token" : user.api_key, @"player" : @{@"username" : userName} };

    [self PATHPlayerDataWithDict:params userID:user.userID onSuccess:success onFailure:failure];
}

- (void)PATCHPlayerWithNewAvatar:(UIImage *)avatar
                       onSuccess:(void (^)())success
                       onFailure:(void (^)(NSError *error,
                                           NSInteger statusCode,
                                           QZBUserRegistrationProblem problem))failure {
    NSString *base64str =
        [@"data:image/jpg;base64," stringByAppendingString:[self encodeToBase64String:avatar]];

    NSDictionary *params = @{
        @"token" : [QZBCurrentUser sharedInstance].user.api_key,
        @"player" : @{@"avatar" : base64str}
    };

    [self PATHPlayerDataWithDict:params userID:nil onSuccess:success onFailure:failure];
}

- (NSString *)encodeToBase64String:(UIImage *)image {
    UIImage *newImage = [self imageWithImage:image scaledToSize:CGSizeMake(200, 200)];
    return [UIImageJPEGRepresentation(newImage, 1.0)
        base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    // UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor
    // (and thus account for
    // Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)PATHPlayerDataWithDict:(NSDictionary *)params
                        userID:(NSNumber *)userID
                     onSuccess:(void (^)())success
                     onFailure:(void (^)(NSError *error,
                                         NSInteger statusCode,
                                         QZBUserRegistrationProblem problem))failure {
    if (!userID) {
        userID = [QZBCurrentUser sharedInstance].user.userID;
    }

    NSString *urlString = [NSString stringWithFormat:@"players/%@", userID];
    [self.requestOperationManager PATCH:urlString
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            DDLogInfo(@"pathed response %@", responseObject);

            if (success) {
                success();
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            DDLogInfo(@"response for patch player %@", operation.responseObject);

            QZBUserRegistrationProblem problem = QZBNoProblems;

            DDLogInfo(@"%@\n responseObject %@", error, operation.responseObject);

            if (![operation.responseObject[@"username"] isEqual:[NSNull null]] &&
                operation.responseObject[@"username"]) {
                NSArray *usernameProblems = operation.responseObject[@"username"];
                // NSString *problem = [usernameProblems firstObject];
                DDLogInfo(@"problem %@", usernameProblems);
                problem = QZBUserNameProblem;
            }

            if (failure) {
                failure(error, operation.response.statusCode, problem);
            }
            DDLogInfo(@"not patched %@", error);
        }];
}

#pragma mark - friend

- (void)POSTFriendWithID:(NSNumber *)userID
               onSuccess:(void (^)(QZBFriendRequest *friendRequest))success
               onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    DDLogInfo(@"user id %@", userID);
    NSDictionary *params =
        @{ @"token" : [QZBCurrentUser sharedInstance].user.api_key,
           @"friend_id" : userID };
    NSString *urlString = @"friend_requests";

    [self.requestOperationManager POST:urlString
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            DDLogInfo(@"friend add request %@", responseObject);

            QZBFriendRequest *fr = [[QZBFriendRequest alloc] initWithDictionary:responseObject];

            if (success)
                success(fr);

        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (failure) {
                failure(error, operation.response.statusCode);
            }

            DDLogInfo(@"not added %@", error);
        }];
}

- (void)DELETEUNFriendWithID:(NSNumber *)userID
                   onSuccess:(void (^)())success
                   onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    DDLogInfo(@"user id %@", userID);
    NSDictionary *params = @{ @"token" : [QZBCurrentUser sharedInstance].user.api_key };
    NSString *urlString = [NSString stringWithFormat:@"friends/%@", userID];

    [self.requestOperationManager DELETE:urlString
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            DDLogInfo(@"deleted %@", responseObject);
            if (success)
                success();

        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (failure) {
                failure(error, operation.response.statusCode);
            }

            DDLogInfo(@"not added %@", error);
        }];
}

- (void)GETFriendsRequestsOnSuccess:(void (^)(NSArray *incoming, NSArray *outgoing))success
                          onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *params = @{ @"token" : [QZBCurrentUser sharedInstance].user.api_key };

    [self.requestOperationManager GET:@"friend_requests"
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            DDLogInfo(@"friends request %@", responseObject);

            NSArray *incomingDicts = responseObject[@"incoming"];
            NSArray *outgoingDicts = responseObject[@"outgoing"];
            NSMutableArray *incomingRequests = [NSMutableArray array];
            NSMutableArray *outgoingRequests = [NSMutableArray array];

            for (NSDictionary *d in incomingDicts) {
                QZBFriendRequest *incomingReq = [[QZBFriendRequest alloc] initWithDictionary:d];
                [incomingRequests addObject:incomingReq];
            }

            for (NSDictionary *d in outgoingDicts) {
                QZBFriendRequest *outgoingReq = [[QZBFriendRequest alloc] initWithDictionary:d];
                [outgoingRequests addObject:outgoingReq];
            }

            NSArray *incoming = [NSArray arrayWithArray:incomingRequests];
            NSArray *outgoing = [NSArray arrayWithArray:outgoingRequests];

            if (success) {
                success(incoming, outgoing);
            }

        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            if (failure) {
                failure(error, operation.response.statusCode);
            }
        }];
}

- (void)PATCHMarkRequestsAsViewedOnSuccess:(void (^)())success
                                 onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *params = @{ @"token" : [QZBCurrentUser sharedInstance].user.api_key };

    [self.requestOperationManager PATCH:@"friendships/mark_requests_as_viewed"
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {

            DDLogInfo(@"match all user success %@", responseObject);

            if (success) {
                success();
            }

        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (failure) {
                failure(error, operation.response.statusCode);
            }
        }];
}

- (void)GETAllFriendsOfUserWithID:(NSNumber *)userID
                        OnSuccess:(void (^)(NSArray *friends))success
                        onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    // NSNumber *userID = [QZBCurrentUser sharedInstance].user.userID;

    NSString *urlString = [NSString stringWithFormat:@"players/%@/friends", userID];

    NSDictionary *params = @{ @"token" : [QZBCurrentUser sharedInstance].user.api_key };

    [self.requestOperationManager GET:urlString
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {

            DDLogInfo(@"all friend %@", responseObject);

            NSMutableArray *friends = [NSMutableArray array];

            for (NSDictionary *dict in responseObject) {
                QZBAnotherUser *user = [[QZBAnotherUser alloc] initWithDictionary:dict];

                [friends addObject:user];
            }

            NSArray *result = [NSArray arrayWithArray:friends];

            if (success) {
                success(result);
            }

        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            DDLogInfo(@"friends error %@", error);

            if (failure) {
                failure(error, operation.response.statusCode);
            }
        }];
}

- (void)GETReportForUserID:(NSNumber *)userID
                   message:(NSString *)reportMessage
                 onSuccess:(void (^)())success
                 onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    NSString *urlString = [NSString stringWithFormat:@"players/%@/report", userID];

    NSDictionary *params =
        @{ @"token" : [QZBCurrentUser sharedInstance].user.api_key,
           @"message" : reportMessage };

    [self.requestOperationManager GET:urlString
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            DDLogInfo(@"report ok");

            if (success) {
                success();
            }

        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DDLogInfo(@"report error %@", error);

            if (failure) {
                failure(error, operation.response.statusCode);
            }
        }];
}

- (void)PATCHAcceptFriendRequestWithID:(NSNumber *)reqID
                             onSuccess:(void (^)())success
                             onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *params = @{ @"token" : [QZBCurrentUser sharedInstance].user.api_key };
    NSString *urlAsString = [NSString stringWithFormat:@"friend_requests/%@", reqID];

    [self.requestOperationManager PATCH:urlAsString
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"response object%@", responseObject);
            if (success) {
                success();
            }

        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (failure) {
                failure(error, operation.response.statusCode);
            }
        }];
}

- (void)DELETEDeclineFriendRequestWithID:(NSNumber *)reqID
                               onSuccess:(void (^)())success
                               onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *params = @{ @"token" : [QZBCurrentUser sharedInstance].user.api_key };
    NSString *urlAsString = [NSString stringWithFormat:@"friend_requests/%@", reqID];

    [self.requestOperationManager DELETE:urlAsString
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"response object %@", responseObject);
            if (success) {
                success();
            }

        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (failure) {
                failure(error, operation.response.statusCode);
            }
        }];
}

#pragma mark - ranking

- (void)GETRankingWeekly:(BOOL)isWeekly
              isCategory:(BOOL)isCategory
                  withID:(NSInteger)ID
               onSuccess:(void (^)(NSArray *topRanking, NSArray *playerRanking))success
               onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    NSMutableString *urlAsString = [NSMutableString stringWithString:@"rankings/"];

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{
        @"token" : [QZBCurrentUser sharedInstance].user.api_key
    }];

    if (isWeekly) {
        params[@"weekly"] = @"true";
    }

    if (ID > 0) {
        if (isCategory) {
            params[@"category_id"] = [NSString stringWithFormat:@"%ld", (long)ID];
            [urlAsString appendString:@"category"];
        } else {
            [urlAsString appendString:@"topic"];
            params[@"topic_id"] = [NSString stringWithFormat:@"%ld", (long)ID];
        }
    } else {
        [urlAsString appendString:@"general"];
    }

    DDLogInfo(@"params ranking %@", params);

    [self.requestOperationManager GET:urlAsString
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

            DDLogInfo(@" %@ ranking JSON: %@", urlAsString, responseObject);

            NSMutableArray *usersTop = [NSMutableArray array];
            NSMutableArray *usersPlayer = [NSMutableArray array];

            [self parseRatingDict:responseObject toTopArray:usersTop playerRating:usersPlayer];

            if (success) {
                success(usersTop, usersPlayer);
            }

            if ([SVProgressHUD isVisible]) {
                [SVProgressHUD dismiss];
            }

        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

            if (failure) {
                failure(error, operation.response.statusCode);
            }

            if (operation.response.statusCode == 0) {
                [SVProgressHUD showErrorWithStatus:QZBNoInternetConnectionMessage];
            }

        }];
}

- (void)parseRatingDict:(NSDictionary *)responseObject
             toTopArray:(NSMutableArray *)usersTop
           playerRating:(NSMutableArray *)usersPlayer {
    NSArray *usersTopArray = responseObject[@"rankings"];
    NSArray *usersPlayerArray = responseObject[@"player_rankings"];

    NSInteger playerPosition = [responseObject[@"position"] integerValue];

    NSInteger position = 1;
    for (NSDictionary *dict in usersTopArray) {
        QZBUserInRating *user = [[QZBUserInRating alloc] initWithDictionary:dict position:position];
        position++;

        [usersTop addObject:user];
    }
    if (usersPlayerArray) {
        position = playerPosition - 4;

        for (NSDictionary *dict in usersPlayerArray) {
            QZBUserInRating *user =
                [[QZBUserInRating alloc] initWithDictionary:dict position:position];
            position++;

            [usersPlayer addObject:user];
        }
        [usersPlayer removeObjectsInArray:usersTop];
    }
}

#pragma mark - APNs token

- (void)POSTAPNsToken:(NSString *)token
            onSuccess:(void (^)())success
            onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    if (!token) {
        return;
    }

    NSDictionary *params =
        @{ @"token" : [QZBCurrentUser sharedInstance].user.api_key,
           @"push_token" : token };

    //[self.requestOperationManager ]

    [self.requestOperationManager POST:@"push_tokens"
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            DDLogInfo(@"token response %@", responseObject);
            if (success) {
                success();
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            DDLogInfo(@"token failure %@", error);
            if (failure) {
                failure(error, operation.response.statusCode);
            }
        }];
}

- (void)PATCHAPNsTokenNew:(NSString *)newToken
                 oldToken:(NSString *)oldToken
                onSuccess:(void (^)())success
                onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *params = @{
        @"token" : [QZBCurrentUser sharedInstance].user.api_key,
        @"old_token" : oldToken,
        @"new_token" : newToken
    };

    [self.requestOperationManager PATCH:@"push_tokens/replace"
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {

            DDLogInfo(@"token replace response %@", responseObject);
            if (success) {
                success();
            }

        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            DDLogInfo(@"token replace failure %@", error);
            if (failure) {
                failure(error, operation.response.statusCode);
            }
        }];
}

- (void)DELETEAPNsToken:(NSString *)token
              onSuccess:(void (^)())success
              onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *params =
        @{ @"token" : [QZBCurrentUser sharedInstance].user.api_key,
           @"push_token" : token };

    [self.requestOperationManager DELETE:@"push_tokens/delete"
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            DDLogInfo(@"token delete response %@", responseObject);
            if (success) {
                success();
            }

        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DDLogInfo(@"token delete failure %@", error);
            if (failure) {
                failure(error, operation.response.statusCode);
            }
        }];
}

#pragma mark - IAP

- (void)GETInAppPurchasesOnSuccess:(void (^)(NSSet *purchases))success
                         onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *params = @{ @"token" : [QZBCurrentUser sharedInstance].user.api_key };

    [self.requestOperationManager GET:@"purchases"
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {

            DDLogInfo(@"GET purchases %@", responseObject);

            NSMutableArray *purchases = [NSMutableArray array];
            for (NSDictionary *dict in responseObject) {
                QZBProduct *product = [[QZBProduct alloc] initWhithDictionary:dict];
                [purchases addObject:product];
            }

            NSSet *result = [NSSet setWithArray:purchases];

            DDLogInfo(@" %@", result);
            if (success) {
                success(result);
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DDLogInfo(@"purchases failure %@", error);

            if (failure) {
                failure(error, operation.response.statusCode);
            }
        }];
}

- (void)POSTInAppPurchaseIdentifier:(NSString *)identifier
                          onSuccess:(void (^)())success
                          onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *params =
        @{ @"token" : [QZBCurrentUser sharedInstance].user.api_key,
           @"identifier" : identifier };

    [self.requestOperationManager POST:@"purchases"
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {

            DDLogInfo(@"post purchases OK %@", responseObject);

            if (success) {
                success();
            }

        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            DDLogInfo(@" purchases failure");
            if (failure) {
                failure(error, operation.response.statusCode);
            }

        }];
}

#pragma mark - search

- (void)GETSearchFriendsWithText:(NSString *)text
                       OnSuccess:(void (^)(NSArray *friends))success
                       onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *params =
        @{ @"token" : [QZBCurrentUser sharedInstance].user.api_key,
           @"query" : text };

    [self.requestOperationManager GET:@"players/search"
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {

            DDLogInfo(@"all friend %@", responseObject);

            NSMutableArray *friends = [NSMutableArray array];

            for (NSDictionary *dict in responseObject) {
                QZBAnotherUser *user = [[QZBAnotherUser alloc] initWithDictionary:dict];
                [friends addObject:user];
            }

            NSArray *result = [NSArray arrayWithArray:friends];

            if (success) {
                success(result);
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            DDLogInfo(@"friends error %@", error);

            if (failure) {
                failure(error, operation.response.statusCode);
            }
        }];
}

#pragma mark - achievements

- (void)GETachievementsForUserID:(NSNumber *)userID
                       onSuccess:(void (^)(NSArray *achievements))success
                       onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    //  NSString *urlString = [NSString stringWithFormat:@"achievements"];
    NSDictionary *params = @{ @"token" : [QZBCurrentUser sharedInstance].user.api_key };

    [self.requestOperationManager GET:@"achievements"
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {

            DDLogInfo(@"%@", operation);

            DDLogInfo(@"achievements %@", responseObject);

            NSArray *achievements = [self parseAchievementsFromArray:responseObject];
            if (success) {
                success(achievements);
            }

        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DDLogInfo(@"achievments error %@", error);

            if (failure) {
                failure(error, operation.response.statusCode);
            }

        }];
}

- (NSArray *)parseAchievementsFromArray:(NSArray *)responseObject {
    NSMutableArray *tmpArr = [NSMutableArray array];

    for (NSDictionary *dict in responseObject) {
        QZBAchievement *achiev = [[QZBAchievement alloc] initWithDictionary:dict];
        [tmpArr addObject:achiev];
    }

    return [NSArray arrayWithArray:tmpArr];
}

#pragma mark - messager notifications

//- (void)POSTSendNotificationAboutMessage:(NSString *)message
//                            toUserWithID:(NSNumber *)userID
//                               onSuccess:(void (^)())success
//                               onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
//    //    NSDictionary *params =
//    //        @{ @"token" : [QZBCurrentUser sharedInstance].user.api_key,
//    //           @"message" : message };
//    NSDictionary *params = @{
//        @"token" : [QZBCurrentUser sharedInstance].user.api_key,
//        @"message" : @{@"content" : message, @"player_id" : userID}
//    };
//
//    NSString *urlString = [NSString stringWithFormat:@"messages"];
//    [self.requestOperationManager POST:urlString
//        parameters:params
//        success:^(AFHTTPRequestOperation *operation, id responseObject) {
//
//            NSLog(@"succes");
//            if (success) {
//                success();
//            }
//        }
//        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//
//            NSLog(@"message error %@", error);
//            if (failure) {
//                failure(error, operation.response.statusCode);
//            }
//
//        }];
//}
//
//- (void)GETAllMessagesForUserId:(NSNumber *)userID
//                      onSuccess:(void (^)(NSArray *messages))success
//                      onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
//    NSDictionary *params =
//        @{ @"token" : [QZBCurrentUser sharedInstance].user.api_key,
//           @"player_id" : userID };
//
//    //  NSString *urlString = [NSString stringWithFormat:@"players/%@/notify", userID];
//
//    [self.requestOperationManager GET:@"messages"
//        parameters:params
//        success:^(AFHTTPRequestOperation *operation, id responseObject) {
//
//            DDLogCVerbose(@"all nessages %@", responseObject);
//
//        }
//        failure:^(AFHTTPRequestOperation *operation, NSError *error){
//
//        }];
//}

-(void)POSTAuthenticateLayerWithNonce:(NSString *) nonce
                             callback:(void (^)(NSString *token, NSError *error))callback {
    
     NSDictionary *params = @{ @"token" : [QZBCurrentUser sharedInstance].user.api_key,
                               @"nonce": nonce
                               };
    
    [self.requestOperationManager POST:@"players/authenticate_layer"
                            parameters:params
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSLog(@"layer auth %@", responseObject);
                                   NSString *token = responseObject[@"token"];
                                   if(callback) {
                                       callback(token, nil);
                                   }
                                   
                                   
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
        DDLogError(@"layer responce %@ identy err %@ status %ld",operation, error, operation.response.statusCode);
        //operation.response
        
        if (callback) {
            callback(nil,error);
        }

    }];
    
}

#pragma mark - rooms

- (void)GETAllRoomsOnSuccess:(void (^)(NSArray *rooms))success
                   onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *params = @{ @"token" : [QZBCurrentUser sharedInstance].user.api_key };

    [self.requestOperationManager GET:@"rooms"
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {

            DDLogCVerbose(@"%@", responseObject);

            //            NSMutableArray *tmpArr = [NSMutableArray array];
            //
            //            for (NSDictionary *d in responseObject) {
            //                QZBRoom *room = [[QZBRoom alloc] initWithDictionary:d];
            //                [tmpArr addObject:room];
            //            }
            //
            //            NSSortDescriptor *sortDescriptor =
            //                [[NSSortDescriptor alloc] initWithKey:@"roomID" ascending:NO];
            //            NSSortDescriptor *friendOnlySortDescriptor = [[NSSortDescriptor alloc]
            //            initWithKey:@"isFriendOnly" ascending:NO];

            NSArray *resultArr = [self parseRoomsFromArray:responseObject];

            if (success) {
                success(resultArr);
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            DDLogError(@"room list error %@", error);
            if (failure) {
                failure(error, operation.response.statusCode);
            }
        }];
}

- (NSArray *)parseRoomsFromArray:(NSArray *)responseObject {
    NSMutableArray *tmpArr = [NSMutableArray array];

    for (NSDictionary *d in responseObject) {
        QZBRoom *room = [[QZBRoom alloc] initWithDictionary:d];
        [tmpArr addObject:room];
    }

    NSSortDescriptor *sortDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"roomID" ascending:NO];
    NSSortDescriptor *friendOnlySortDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"isFriendOnly" ascending:NO];

    NSArray *resultArr =
        [tmpArr sortedArrayUsingDescriptors:@[ friendOnlySortDescriptor, sortDescriptor ]];

    return resultArr;
}

- (void)GETRoomWithID:(NSNumber *)roomID
            OnSuccess:(void (^)(QZBRoom *room))success
            onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *params = @{ @"token" : [QZBCurrentUser sharedInstance].user.api_key };

    NSString *urlAsString = [NSString stringWithFormat:@"rooms/%@", roomID];

    [self.requestOperationManager GET:urlAsString
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {

            DDLogCVerbose(@"reload room %@", responseObject);

            QZBRoom *r = [[QZBRoom alloc] initWithDictionary:responseObject];
            if (success) {
                success(r);
            }

        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            DDLogError(@"room list error %@", error);
            if (failure) {
                failure(error, operation.response.statusCode);
            }
        }];
}

- (void)POSTCreateRoomWithTopic:(QZBGameTopic *)topic
                        private:(BOOL)isPrivate
                           size:(NSNumber *)size
                      OnSuccess:(void (^)(QZBRoom *room))success
                      onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *params = @{
        @"token" : [QZBCurrentUser sharedInstance].user.api_key,
        @"room" : @{@"topic_id" : topic.topic_id, @"friends_only" : @(isPrivate), @"size" : size}
    };
    [self.requestOperationManager POST:@"rooms"
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {

            DDLogCVerbose(@"room create %@", responseObject);

            QZBRoom *r = [[QZBRoom alloc] initWithDictionary:responseObject];

            if (success) {
                success(r);
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            DDLogError(@"create room error %@", error);

            if (failure) {
                failure(error, operation.response.statusCode);
            }

        }];
}

- (void)POSTJoinRoomWithID:(NSNumber *)roomID
                 withTopic:(QZBGameTopic *)topic
                 onSuccess:(void (^)())success
                 onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *params =
        @{ @"token" : [QZBCurrentUser sharedInstance].user.api_key,
           @"topic_id" : topic.topic_id };

    NSString *urlAsString = [NSString stringWithFormat:@"rooms/%@/join", roomID];

    [self.requestOperationManager POST:urlAsString
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {

            DDLogCVerbose(@"join room response %@", responseObject);
            // QZBRoom *r = [[QZBRoom alloc] initWithDictionary:responseObject];

            if (success) {
                success();
            }

        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            if (failure) {
                failure(error, operation.response.statusCode);
            }

        }];
}

- (void)DELETELeaveRoomWithID:(NSNumber *)roomID
                    onSuccess:(void (^)())success
                    onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *params = @{ @"token" : [QZBCurrentUser sharedInstance].user.api_key };

    NSString *urlAsString = [NSString stringWithFormat:@"rooms/%@/leave", roomID];

    [self.requestOperationManager DELETE:urlAsString
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {

            DDLogVerbose(@"room leaved");
            if (success) {
                success();
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            DDLogError(@"room leave error %@", error);
            if (failure) {
                failure(error, operation.response.statusCode);
            }
        }];
}

- (void)DELETEDeleteRoomWithID:(NSNumber *)roomID
                     onSuccess:(void (^)())success
                     onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *params = @{ @"token" : [QZBCurrentUser sharedInstance].user.api_key };
    NSString *urlAsString = [NSString stringWithFormat:@"rooms/%@", roomID];

    [self.requestOperationManager DELETE:urlAsString
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {

            DDLogVerbose(@"room deleted");
            if (success) {
                success();
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            DDLogCError(@"deletionFailure, err %@", error);

            if (failure) {
                failure(error, operation.response.statusCode);
            }

        }];
}

- (void)POSTStartRoomWithID:(NSNumber *)roomID
                  onSuccess:(void (^)())success
                  onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *params = @{ @"token" : [QZBCurrentUser sharedInstance].user.api_key };
    NSString *urlAsString = [NSString stringWithFormat:@"rooms/%@/start", roomID];

    [self.requestOperationManager POST:urlAsString
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            DDLogCVerbose(@"room started");
            if (success) {
                success();
            }

        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            DDLogCError(@"startingRoomFailure, err %@", error);

            if (failure) {
                failure(error, operation.response.statusCode);
            }
        }];
}

- (void)POSTAnswerRoomQuestionWithID:(NSInteger)questionID
                            answerID:(NSInteger)answerID
                                time:(NSInteger)time
                           onSuccess:(void (^)())success
                           onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *params = @{
        @"token" : [QZBCurrentUser sharedInstance].user.api_key,

        @"room_answer" : @{@"answer_id" : @(answerID), @"time" : @(time)}
    };

    NSString *urlAsString = [NSString stringWithFormat:@"room_questions/%@/answer", @(questionID)];

    [self.requestOperationManager POST:urlAsString
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"room quest pathed");
            if (success) {
                success();
            }

        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DDLogCError(@"post answer err %@ \n response object %@", error,
                        operation.responseObject);

            if (failure) {
                failure(error, operation.response.statusCode);
            }
        }];
}

- (void)POSTFinishRoomSessionWithID:(NSNumber *)roomID
                          onSuccess:(void (^)())success
                          onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *params = @{ @"token" : [QZBCurrentUser sharedInstance].user.api_key };
    NSString *urlAsString = [NSString stringWithFormat:@"rooms/%@/finish", roomID];

    [self.requestOperationManager POST:urlAsString
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {

            DDLogCVerbose(@"room closed");
            if (success) {
                success();
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DDLogError(@"room closed error %@", error);
            if (failure) {
                failure(error, operation.response.statusCode);
            }
        }];
}

- (void)POSTInviteFriendWithID:(NSNumber *)userID
                  inRoomWithID:(NSNumber *)roomID
                     onSuccess:(void (^)())success
                     onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *params = @{
        @"token" : [QZBCurrentUser sharedInstance].user.api_key,
        @"invite" : @{

            @"room_id" : roomID,
            @"player_id" : userID

        }
    };
    //    {
    //        "invite": {
    //            "room_id": "1",
    //            "player_id": "2"
    //        }
    //    }

    NSString *urlAsString = [NSString stringWithFormat:@"invites"];

    [self.requestOperationManager POST:urlAsString
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            DDLogCVerbose(@"friend invited");
            if (success) {
                success();
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DDLogError(@"friend invited error %@", error);
            if (failure) {
                failure(error, operation.response.statusCode);
            }
        }];
}

- (void)DELETEDeleteRoomInviteWithID:(NSNumber *)inviteID
                           onSuccess:(void (^)())success
                           onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *params = @{ @"token" : [QZBCurrentUser sharedInstance].user.api_key };
    NSString *urlAsString = [NSString stringWithFormat:@"invites/%@", inviteID];

    [self.requestOperationManager DELETE:urlAsString
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {

            DDLogCVerbose(@"room invite deleted");
            if (success) {
                success();
            }

        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DDLogError(@"room invite deletion error %@", error);
            if (failure) {
                failure(error, operation.response.statusCode);
            }
        }];
}

- (void)PATCHParticipationWithID:(NSNumber *)userID
                         isReady:(BOOL)isReady
                       onSuccess:(void (^)())success
                       onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *params = @{
        @"token" : [QZBCurrentUser sharedInstance].user.api_key,
        @"participation" : @{@"ready" : @(isReady)}
    };
    NSString *urlAsString = [NSString stringWithFormat:@"participations/%@", userID];

    [self.requestOperationManager PATCH:urlAsString
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            DDLogCVerbose(@"user ready patched");

            if (success) {
                success();
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DDLogError(@"user ready error %@", error);
            if (failure) {
                failure(error, operation.response.statusCode);
            }
        }];
}

- (void)GETResultsOfRoomSessionWithID:(NSNumber *)roomID
                            onSuccess:(void (^)(QZBRoomSessionResults *sessionResults))success
                            onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *params = @{ @"token" : [QZBCurrentUser sharedInstance].user.api_key };
    NSString *urlAsString = [NSString stringWithFormat:@"room_sessions/%@", roomID];

    [self.requestOperationManager GET:urlAsString
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            DDLogVerbose(@"session results %@", responseObject);

            QZBRoomSessionResults *rsr =
                [[QZBRoomSessionResults alloc] initWithDictionary:responseObject];

            if (success) {
                success(rsr);
            }

        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DDLogError(@"room session get error %@", error);
            if (failure) {
                failure(error, operation.response.statusCode);
            }

        }];
}

- (void)POSTReportForDevelopersWithMessage:(NSString *)message
                                 onSuccess:(void (^)())success
                                 onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *params =
        @{ @"token" : [QZBCurrentUser sharedInstance].user.api_key,
           @"message" : message };

    [self.requestOperationManager POST:@"reports"
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            DDLogCVerbose(@"report sended");
            if (success) {
                success();
            }

        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DDLogError(@"report error %@", error);

            if (failure) {
                failure(error, operation.response.statusCode);
            }
        }];
}

@end
