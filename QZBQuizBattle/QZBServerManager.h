//
//  QZBServerManager.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 24/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "QZBUserProtocol.h"

UIKIT_EXTERN NSString *const QZBServerBaseUrl;
UIKIT_EXTERN NSString *const QZBNoInternetConnectionMessage;

@class QZBSession;
@class QZBLobby;
@class QZBOpponentBot;
@class QZBUser;
@class QZBCategory;
@class QZBGameTopic;
@class QZBAnotherUser;
@class QZBFriendRequest;
@class QZBRoom;
@class QZBRoomSessionResults;

typedef NS_ENUM(NSInteger, QZBUserRegistrationProblem) {
    QZBNoProblems,
    QZBUserNameProblem,
    QZBEmailProblem
};

@interface QZBServerManager : NSObject
@property (copy, nonatomic, readonly) NSString *baseURL;

+ (QZBServerManager *)sharedManager;

- (void)GETCategoriesOnSuccess:(void (^)(NSArray *topics))successAF
                     onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

- (void)GETTopicsWithCategory:(QZBCategory *)category
                    onSuccess:(void (^)(NSArray *topics))successAF
                    onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

- (void)GETTopicsForMainOnSuccess:(void (^)(NSDictionary *resultDict))success
                        onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

//- (QZBCategory *)tryFindRelatedCategoryToTopic:(QZBGameTopic *)topic;

#pragma mark - game

- (void)POSTLobbyWithTopic:(QZBGameTopic *)topic
                 onSuccess:(void (^)(QZBLobby *lobby))success
                 onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

- (void)PATCHCloseLobby:(QZBLobby *)lobby
              onSuccess:(void (^)(QZBSession *session, id bot))success
              onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

- (void)GETFindGameWithLobby:(QZBLobby *)lobby
                   onSuccess:(void (^)(QZBSession *session, id bot))success
                   onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

- (void)PATCHSessionQuestionWithID:(NSInteger)sessionQuestionID
                            answer:(NSInteger)answerID
                              time:(NSInteger)answerTime
                         onSuccess:(void (^)())success
                         onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

- (void)PATCHCloseSessionID:(NSNumber *)sessionID
                  onSuccess:(void (^)())success
                  onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

#pragma mark - challenge

- (void)POSTLobbyChallengeWithUserID:(NSNumber *)userID
                             inTopic:(QZBGameTopic *)topic
                           onSuccess:(void (^)(QZBSession *session))success
                           onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

- (void)POSTAcceptChallengeWhithLobbyID:(NSNumber *)lobbyID
                              onSuccess:(void (^)(QZBSession *session, id bot))success
                              onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

- (void)POSTDeclineChallengeWhithLobbyID:(NSNumber *)lobbyID
                               onSuccess:(void (^)())success
                               onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;
- (void)GETThrownChallengesOnSuccess:(void (^)(NSArray *challenges))success
                           onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

- (void)DELETELobbiesWithID:(NSNumber *)lobbyID
                  onSuccess:(void (^)())success
                  onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

- (void)PATCHMakeChallengeOfflineWithNumber:(NSNumber *)sessionID
                                  onSuccess:(void (^)())success
                                  onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

#pragma mark - user registration and login

- (void)POSTRegistrationUser:(NSString *)userName
                       email:(NSString *)userEmail
                    password:(NSString *)password
                   onSuccess:(void (^)(QZBUser *user))success
                   onFailure:(void (^)(NSError *error,
                                       NSInteger statusCode,
                                       QZBUserRegistrationProblem problem))failure;

- (void)POSTLoginUserName:(NSString *)username
                 password:(NSString *)password
                onSuccess:(void (^)(QZBUser *user))success
                onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

- (void)GETPlayerWithID:(NSNumber *)playerID
              onSuccess:(void (^)(QZBAnotherUser *anotherUser))success
              onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

- (void)POSTAuthWithVKToken:(NSString *)token
                  onSuccess:(void (^)(QZBUser *user))success
                  onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

- (void)POSTPasswordResetWithEmail:(NSString *)userEmail
                         onSuccess:(void (^)())success
                         onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

#pragma mark - user update
- (void)PATCHPlayerWithNewPassword:(NSString *)password
                         onSuccess:(void (^)())success
                         onFailure:(void (^)(NSError *error,
                                             NSInteger statusCode,
                                             QZBUserRegistrationProblem problem))failure;

- (void)PATCHPlayerWithNewUserName:(NSString *)userName
                         onSuccess:(void (^)())success
                         onFailure:(void (^)(NSError *error,
                                             NSInteger statusCode,
                                             QZBUserRegistrationProblem problem))failure;
- (void)PATCHPlayerWithNewAvatar:(UIImage *)avatar
                       onSuccess:(void (^)())success
                       onFailure:(void (^)(NSError *error,
                                           NSInteger statusCode,
                                           QZBUserRegistrationProblem problem))failure;

- (void)PATCHPlayerWithNewUserNameThenRegistration:(NSString *)userName
                                              user:(QZBUser *)user
                                         onSuccess:(void (^)())success
                                         onFailure:
                                             (void (^)(NSError *error,
                                                       NSInteger statusCode,
                                                       QZBUserRegistrationProblem problem))failure;

#pragma mark - friends

- (void)POSTFriendWithID:(NSNumber *)userID
               onSuccess:(void (^)(QZBFriendRequest *friendRequest)) success
               onFailure:(void (^)(NSError *error, NSInteger statusCode))failure ;

- (void)DELETEUNFriendWithID:(NSNumber *)userID
                   onSuccess:(void (^)())success
                   onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

- (void)GETAllFriendsOfUserWithID:(NSNumber *)userID
                        OnSuccess:(void (^)(NSArray *friends))success
                        onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

- (void)GETFriendsRequestsOnSuccess:(void (^)(NSArray *incoming, NSArray *outgoing))success
                          onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;
- (void)PATCHMarkRequestsAsViewedOnSuccess:(void (^)())success
                                 onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

- (void)GETReportForUserID:(NSNumber *)userID
                   message:(NSString *)reportMessage
                 onSuccess:(void (^)())success
                 onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

- (void)PATCHAcceptFriendRequestWithID:(NSNumber *)reqID
                             onSuccess:(void (^)())success
                             onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

- (void)DELETEDeclineFriendRequestWithID:(NSNumber *)reqID
                               onSuccess:(void (^)())success
                               onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

#pragma mark - rate
- (void)GETRankingWeekly:(BOOL)isWeekly
              isCategory:(BOOL)isCategory
                  withID:(NSInteger)ID
               onSuccess:(void (^)(NSArray *topRanking, NSArray *playerRanking))success
               onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

- (NSString *)hashPassword:(NSString *)password;

#pragma mark - APNs tokens

- (void)POSTAPNsToken:(NSString *)token
            onSuccess:(void (^)())success
            onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

- (void)PATCHAPNsTokenNew:(NSString *)newToken
                 oldToken:(NSString *)oldToken
                onSuccess:(void (^)())success
                onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

- (void)DELETEAPNsToken:(NSString *)token
              onSuccess:(void (^)())success
              onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

#pragma mark - IAP

- (void)GETInAppPurchasesOnSuccess:(void (^)(NSSet *purchases))success
                         onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

- (void)POSTInAppPurchaseIdentifier:(NSString *)identifier
                          onSuccess:(void (^)())success
                          onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

#pragma mark - search

- (void)GETSearchFriendsWithText:(NSString *)text
                       OnSuccess:(void (^)(NSArray *friends))success
                       onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

#pragma mark - achievements

- (void)GETachievementsForUserID:(NSNumber *)userID
                       onSuccess:(void (^)(NSArray *achievements))success
                       onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

#pragma mark - messager notifications

-(void)POSTSendNotificationAboutMessage:(NSString *)message
                           toUserWithID:(NSNumber *)userID
                              onSuccess:(void (^)())success
                              onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

#pragma mark - rooms

- (void)GETAllRoomsOnSuccess:(void (^)(NSArray *rooms))success
                   onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

- (void)GETRoomWithID:(NSNumber *)roomID OnSuccess:(void (^)(QZBRoom *room))success
            onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

- (void)POSTCreateRoomWithTopic:(QZBGameTopic *)topic
                        private:(BOOL)isPrivate
                           size:(NSNumber *)size
                      OnSuccess:(void (^)(QZBRoom *room))success
                      onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

- (void)POSTJoinRoomWithID:(NSNumber *)roomID
                 withTopic:(QZBGameTopic *)topic
                 onSuccess:(void (^)())success
                 onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

- (void)DELETELeaveRoomWithID:(NSNumber *)roomID onSuccess:(void (^)())success
                    onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;


- (void)DELETEDeleteRoomWithID:(NSNumber *)roomID
                     onSuccess:(void (^)())success
                     onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

- (void)POSTStartRoomWithID:(NSNumber *)roomID
                  onSuccess:(void (^)())success
                  onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

-(void)POSTAnswerRoomQuestionWithID:(NSInteger) questionID
                            answerID:(NSInteger) answerID
                                time:(NSInteger) time
                           onSuccess:(void (^)())success
                           onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

-(void)POSTFinishRoomSessionWithID:(NSNumber *)roomID onSuccess:(void (^)())success
                         onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

- (void)PATCHParticipationWithID:(NSNumber *)userID
                         isReady:(BOOL)isReady
                       onSuccess:(void (^)())success
                       onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;


- (void)GETResultsOfRoomSessionWithID:(NSNumber *)roomID
                            onSuccess:(void (^)(QZBRoomSessionResults *sessionResults))success
                            onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;



@end
