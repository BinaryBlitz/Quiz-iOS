//
//  QZBServerManager.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 24/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>


@class QZBSession;
@class QZBLobby;
@class QZBOpponentBot;
@class QZBUser;
@class QZBCategory;
@class QZBGameTopic;

@interface QZBServerManager : NSObject

+ (QZBServerManager*) sharedManager ;


- (void) getСategoriesOnSuccess:(void(^)(NSArray* topics)) successAF
onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

- (void) getTopicsWithCategory:(QZBCategory *) category
                     onSuccess:(void(^)(NSArray* topics)) successAF
                     onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

- (void)POSTLobbyWithTopic:(QZBGameTopic *)topic
                 onSuccess:(void (^)(QZBLobby *lobby))success
                 onFailure:(void (^)(NSError *error,
                                     NSInteger statusCode))failure;
- (void)PATCHCloseLobby:(QZBLobby *)lobby
              onSuccess:(void (^)(QZBSession *session,
                                  id bot))success
              onFailure:(void (^)(NSError *error,
                                  NSInteger statusCode))failure;

- (void)GETFindGameWithLobby:(QZBLobby *)lobby
                   onSuccess:(void (^)(QZBSession *session,
                                       id bot))success
                   onFailure:(void (^)(NSError *error,
                                       NSInteger statusCode))failure;


-(void)PATCHSessionQuestionWithID:(NSInteger)sessionQuestionID
                           answer:(NSInteger)answerID
                             time:(NSInteger)answerTime
                        onSuccess:(void(^)()) success
                        onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;


-(void)POSTRegistrationUser:(NSString *)userName
                      email:(NSString *)userEmail
                   password:(NSString *)password
                  onSuccess:(void(^)(QZBUser *user)) success
                  onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;


-(void)POSTLoginUserEmail:(NSString *)email
                 password:(NSString *)password
                onSuccess:(void(^)(QZBUser *user)) success
                onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

-(NSString *)hashPassword:(NSString *)password;

@end
