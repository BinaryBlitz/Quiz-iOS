//
//  QZBServerManager.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 24/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#define MR_LOGGING_ENABLED 0

#import "QZBServerManager.h"
#import "QZBGameTopic.h"
#import "QZBLobby.h"
#import "QZBSession.h"
#import "QZBCategory.h"
#import "QZBOpponentBot.h"
#import "QZBOnlineSessionWorker.h"
#import "QZBUser.h"
#import "QZBCurrentUser.h"
#import "NSString+MD5.h"
#import "CoreData+MagicalRecord.h"
#import "TSMessage.h"

@interface QZBServerManager ()
@property(strong, nonatomic)
    AFHTTPRequestOperationManager *requestOperationManager;
@end

@implementation QZBServerManager

+ (QZBServerManager *)sharedManager {
  static QZBServerManager *manager = nil;

  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{ manager = [[QZBServerManager alloc] init]; });

  return manager;
}

- (id)init {
  self = [super init];
  if (self) {
    NSURL *url =
        [NSURL URLWithString:@"https://protected-atoll-5061.herokuapp.com/"];

    self.requestOperationManager =
        [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
  }
  return self;
}

#pragma mark - categories and topics

- (void)getСategoriesOnSuccess:(void (^)(NSArray *topics))successAF
                     onFailure:(void (^)(NSError *error,
                                         NSInteger statusCode))failure {
  NSDictionary *params = @{
    @"token" : [QZBCurrentUser sharedInstance].user.api_key
  };

  [self.requestOperationManager GET:@"categories"
      parameters:params
      success:^(AFHTTPRequestOperation *operation, NSArray *responseObject) {
          NSLog(@"JSON: %@", responseObject);

          NSMutableArray *objectsArray = [NSMutableArray array];

          for (NSDictionary *dict in responseObject) {
            NSString *name = [dict objectForKey:@"name"];
            id category_id = [dict objectForKey:@"id"];

            // NSLog(@"%@ %@", name, category_id);

            QZBCategory *existingEntity =
                [QZBCategory MR_findFirstByAttribute:@"category_id"
                                           withValue:category_id];

            if (!existingEntity) {
              existingEntity = [QZBCategory MR_createEntity];
              existingEntity.category_id = category_id;
              existingEntity.name = name;
            }
            [objectsArray addObject:existingEntity];
          }

          // NSLog(@"%@", [objectsArray debugDescription]);

          NSMutableArray *allCategories =
              [[QZBCategory MR_findAll] mutableCopy];

          [allCategories removeObjectsInArray:objectsArray];

          if (allCategories) {
            for (QZBCategory *categ in allCategories) {
              [categ MR_deleteEntity];
            }
          }

          [MagicalRecord saveUsingCurrentThreadContextWithBlock:
                             nil completion:^(BOOL success, NSError *error) {
                                 if (success) {
                                   successAF([QZBCategory MR_findAll]);
                                 }
                             }];

      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"Error: %@", error);

          if (failure) {
            failure(error, operation.response.statusCode);
          }
      }];
}

- (void)getTopicsWithCategory:(QZBCategory *)category
                    onSuccess:(void (^)(NSArray *topics))successAF
                    onFailure:(void (^)(NSError *error,
                                        NSInteger statusCode))failure {
  NSDictionary *params = @{
    @"token" : [QZBCurrentUser sharedInstance].user.api_key
  };

  NSString *urlAsString =
      [NSString stringWithFormat:@"categories/%@", category.category_id];

  [self.requestOperationManager GET:urlAsString
      parameters:params
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSLog(@"JSON: %@", responseObject);

          NSArray *topics = [responseObject objectForKey:@"topics"];

          NSMutableArray *objectsArray = [NSMutableArray array];

          for (NSDictionary *dict in topics) {
            NSString *name = [dict objectForKey:@"name"];
            id topic_id = [dict objectForKey:@"id"];

            QZBGameTopic *existingEntity =
                [QZBGameTopic MR_findFirstByAttribute:@"topic_id"
                                            withValue:topic_id];

            if (!existingEntity) {
              existingEntity = [QZBGameTopic MR_createEntity];
              existingEntity.name = name;
              existingEntity.topic_id = topic_id;

              [category addRelationToTopicObject:existingEntity];
            }
            [objectsArray addObject:existingEntity];
          }

          NSMutableArray *allTopics = [NSMutableArray
              arrayWithArray:[[category relationToTopic] allObjects]];

          [allTopics removeObjectsInArray:objectsArray];

          if (allTopics) {
            for (QZBGameTopic *topic in allTopics) {
              [topic MR_deleteEntity];
            }
          }

          [MagicalRecord
              saveUsingCurrentThreadContextWithBlock:nil
                                          completion:^(BOOL success,
                                                       NSError *error) {

                                              if (successAF) {
                                                successAF(objectsArray);
                                              }

                                          }];

      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"Error: %@", error);

          if (failure) {
            failure(error, operation.response.statusCode);
          }
      }];
}

#pragma mark - session methods

- (void)POSTLobbyWithTopic:(QZBGameTopic *)topic
                 onSuccess:(void (^)(QZBLobby *lobby))success
                 onFailure:(void (^)(NSError *error,
                                     NSInteger statusCode))failure {
  NSDictionary *params = @{
    @"lobby" : @{@"topic_id" : topic.topic_id},
    @"token" : [QZBCurrentUser sharedInstance].user.api_key
  };

  [self.requestOperationManager POST:@"lobbies"
      parameters:params
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSLog(@"lobby: %@  ", responseObject);

          QZBLobby *lobby = [[QZBLobby alloc] initWithDict:responseObject];

          if (success) {
            success(lobby);
          }

      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"%@, /n %@", operation, error);

          if (failure) {
            failure(error, operation.response.statusCode);
          }

      }];
}

- (void)GETFindGameWithLobby:(QZBLobby *)lobby
                   onSuccess:(void (^)(QZBSession *session, id bot))success
                   onFailure:(void (^)(NSError *error,
                                       NSInteger statusCode))failure {
  NSDictionary *params = @{
    @"token" : [QZBCurrentUser sharedInstance].user.api_key
  };

  NSString *URLString =
      [NSString stringWithFormat:@"lobbies/%ld/find", (long)lobby.lobbyID];

  NSLog(@"%@", URLString);

  [self.requestOperationManager GET:URLString
      parameters:params
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
          NSLog(@"JSON: %@", responseObject);

          if (responseObject) {
            QZBSession *session =
                [[QZBSession alloc] initWIthDictionary:responseObject];

            id bot = nil;

            NSNumber *isOffline = responseObject[@"offline"];

            if ([isOffline isEqual:@1]) {
              bot = [[QZBOpponentBot alloc] initWithDictionary:responseObject];
            } else {
              
            }
            if (success) {
              success(session, bot);
            }
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error){

       //  NSLog(@"%@, /n %@", operation, error);
      }];
}

- (void)PATCHCloseLobby:(QZBLobby *)lobby
              onSuccess:(void (^)(QZBSession *session, id bot))success
              onFailure:(void (^)(NSError *error,
                                  NSInteger statusCode))failure {
  NSDictionary *params = @{
    @"token" : [QZBCurrentUser sharedInstance].user.api_key
  };

  NSString *URLString =
      [NSString stringWithFormat:@"lobbies/%ld/close", (long)lobby.lobbyID];

  NSLog(@"%@", URLString);

  [self.requestOperationManager PATCH:URLString
      parameters:params
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSLog(@"lobby closed");
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error){

      }];
}

- (void)postSessionWithTopic:(QZBGameTopic *)topic
                   onSuccess:(void (^)(QZBSession *session,
                                       QZBOpponentBot *bot))success
                   onFailure:(void (^)(NSError *error,
                                       NSInteger statusCode))failure {
  NSDictionary *params = @{
    @"game_session" : @{
      @"host_id" : [QZBCurrentUser sharedInstance].user.user_id,
      @"topic_id" : topic.topic_id
    },
    @"token" : [QZBCurrentUser sharedInstance].user.api_key
  };

  [self.requestOperationManager POST:@"game_sessions"
      parameters:params
      success:^(AFHTTPRequestOperation *operation, id responseObject) {

          NSLog(@"JSON: %@", responseObject);
          QZBSession *session =
              [[QZBSession alloc] initWIthDictionary:responseObject];

          QZBOpponentBot *bot =
              [[QZBOpponentBot alloc] initWithDictionary:responseObject];

          if (success) {
            success(session, bot);
          }

      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"%@, /n %@", operation, error);

          if (failure) {
            failure(error, operation.response.statusCode);
          }

      }];
}

//отправляет данные о ходе пользователя
- (void)PATCHSessionQuestionWithID:(NSInteger)sessionQuestionID
                            answer:(NSInteger)answerID
                              time:(NSInteger)answerTime
                         onSuccess:(void (^)())success
                         onFailure:(void (^)(NSError *error,
                                             NSInteger statusCode))failure {
  NSDictionary *params = @{
    @"game_session_question" :
        @{@"host_answer_id" : @(answerID), @"host_time" : @(answerTime)},
    @"token" : [QZBCurrentUser sharedInstance].user.api_key
  };

  NSString *URLString = [NSString
      stringWithFormat:@"game_session_questions/%ld", (long)sessionQuestionID];

  [self.requestOperationManager PATCH:URLString
      parameters:params
      success:^(AFHTTPRequestOperation *operation, id responseObject) {

          NSLog(@"patched");

      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {

          NSLog(@"%@", error);

      }];
}

#pragma mark - user registration

- (NSString *)hashPassword:(NSString *)password {
  return [password MD5];
}

- (void)POSTRegistrationUser:(NSString *)userName
                       email:(NSString *)userEmail
                    password:(NSString *)password
                   onSuccess:(void (^)(QZBUser *user))success
                   onFailure:(void (^)(NSError *error,
                                       NSInteger statusCode))failure {
  NSString *hashedPassword = [self hashPassword:password];

  NSLog(@"hashed %@", hashedPassword);

  NSDictionary *params = @{
    @"player" : @{
      @"name" : userName,
      @"email" : userEmail,
      @"password_digest" : hashedPassword
    }
  };

  [self.requestOperationManager POST:@"players"
      parameters:params
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSLog(@"%@", responseObject);

          QZBUser *user = [[QZBUser alloc] initWithDict:responseObject];

          if (success) {
            success(user);
          }

      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {

          if (failure) {
            failure(error, operation.response.statusCode);
          }
          NSLog(@"%@", error);
      }];
}

- (void)POSTLoginUserEmail:(NSString *)email
                  password:(NSString *)password
                 onSuccess:(void (^)(QZBUser *user))success
                 onFailure:(void (^)(NSError *error,
                                     NSInteger statusCode))failure {
  NSString *hashedPassword = [self hashPassword:password];

  NSLog(@"email %@ password %@", email, hashedPassword);

  NSDictionary *params = @{
    @"email" : email,
    @"password_digest" : hashedPassword
  };

  [self.requestOperationManager POST:@"players/authenticate"
      parameters:params
      success:^(AFHTTPRequestOperation *operation, id responseObject) {

          NSLog(@"resp %@", responseObject);

          if (![responseObject objectForKey:@"error"]) {
            QZBUser *user = [[QZBUser alloc] initWithDict:responseObject];

            if (success) {
              success(user);
            }
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"%@", error);
          if (failure) {
            failure(error, operation.response.statusCode);
          }

      }];
}

@end
