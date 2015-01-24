//
//  QZBServerManager.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 24/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import "QZBServerManager.h"
#import "QZBGameTopic.h"
#import "QZBSession.h"
#import "QZBCategory.h"
#import "QZBOpponentBot.h"
#import "QZBUser.h"
#import "QZBCurrentUser.h"
#import "JFBCrypt.h"
#import "NSString+MD5.h"
#import "CoreData+MagicalRecord.h"

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

          // [QZBCategory MR_truncateAll];

          NSMutableArray *objectsArray = [NSMutableArray array];

          //  NSArray *objectsBeforeAdding = [QZBCategory
          //  MR_findAllSortedBy:@"category_id" ascending:YES];

          for (NSDictionary *dict in responseObject) {
            NSString *name = [dict objectForKey:@"name"];
            id category_id = [dict objectForKey:@"id"];

            NSLog(@"%@ %@", name, category_id);

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

          NSLog(@"%@", [objectsArray debugDescription]);

          NSMutableArray *allCategories = [[QZBCategory MR_findAll] mutableCopy];
        
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
        
         NSMutableArray *allTopics = [NSMutableArray arrayWithArray:[[category relationToTopic] allObjects]];
        
        [allTopics removeObjectsInArray:objectsArray];
        
        if(allTopics){
          for(QZBGameTopic *topic in allTopics){
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

- (void)postSessionWithTopic:(QZBGameTopic *)topic
                   onSuccess:(void (^)(QZBSession *session,
                                       QZBOpponentBot *bot))success
                   onFailure:(void (^)(NSError *error,
                                       NSInteger statusCode))failure {
  NSDictionary *params = @{
    @"game_session" : @{@"host_id" : @(1), @"topic_id" : topic.topic_id},
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
      stringWithFormat:@"game_session_questions/%ld", sessionQuestionID];

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

  // email = @"foo@bar.com";

  // hashedPassword =
  // @"$2a$10$qfOWhGZO92uXKTjYzzb/9efimcojZOHrTEe0NQPuXVKWljZ1N1mfy";

  NSDictionary *params = @{
    @"email" : email,
    @"password_digest" : hashedPassword
  };

  [self.requestOperationManager POST:@"players/authenticate"
      parameters:params
      success:^(AFHTTPRequestOperation *operation, id responseObject) {

          NSLog(@"resp %@", responseObject);

          NSString *token = [responseObject objectForKey:@"token"];

          /*
           self.api_key = [dict objectForKey:@"api_key"];
           self.name = [dict objectForKey:@"name"];
           self.email = [dict objectForKey:@"email"];

           */

          if (![responseObject objectForKey:@"error"]) {
            NSString *name = [responseObject objectForKey:@"name"];

            NSDictionary *dict = @{
              @"api_key" : token,
              @"name" : name,
              @"email" : email
            };  // redo name

            QZBUser *user = [[QZBUser alloc] initWithDict:dict];

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
