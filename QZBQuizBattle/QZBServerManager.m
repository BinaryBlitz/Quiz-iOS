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

@interface QZBServerManager()
@property (strong, nonatomic) AFHTTPRequestOperationManager* requestOperationManager;
@end

@implementation QZBServerManager

+ (QZBServerManager*) sharedManager {
  
  static QZBServerManager* manager = nil;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    manager = [[QZBServerManager alloc] init];
  });
  
  return manager;
}

- (id)init
{
  self = [super init];
  if (self) {
    
    NSURL* url = [NSURL URLWithString:@"https://protected-atoll-5061.herokuapp.com/"];
    
    self.requestOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
  }
  return self;
}



- (void) getСategoriesOnSuccess:(void(^)(NSArray* topics)) success
               onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {

                 NSDictionary *params = @{@"token":[QZBCurrentUser sharedInstance].user.api_key};
                 
  [self.requestOperationManager
   GET:@"categories"
   parameters:params
   success:^(AFHTTPRequestOperation *operation, NSArray* responseObject) {
     NSLog(@"JSON: %@", responseObject);
     
     
     
     NSMutableArray* objectsArray = [NSMutableArray array];
     
     for (NSDictionary* dict in responseObject) {

       QZBCategory *category = [[QZBCategory alloc] initWithDict:dict];
       
       [objectsArray addObject:category];
      
     }
     
     if (success) {
       success(objectsArray);
     }
     
   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
     NSLog(@"Error: %@", error);
     
     if (failure) {
       failure(error, operation.response.statusCode);
     }
   }];
  
}



- (void) getTopicsWithID:(NSInteger) ID
               onSuccess:(void(^)(NSArray* topics)) success
                    onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
  
  NSDictionary* params =@{@"ID":@(ID),@"token":[QZBCurrentUser sharedInstance].user.api_key};
  
  
  [self.requestOperationManager
   GET:@"topics"
   parameters:params
   success:^(AFHTTPRequestOperation *operation, NSArray* responseObject) {
     NSLog(@"JSON: %@", responseObject);
     
     //NSArray* dictsArray = [responseObject objectForKey:@"topics"];
     //NSLog(@"%@", [responseObject firstObject]);
     
     NSMutableArray* objectsArray = [NSMutableArray array];
     
     for (NSDictionary* dict in responseObject) {
       QZBGameTopic *topic = [[QZBGameTopic alloc] initWithDictionary:dict];
       
       [objectsArray addObject:topic];
     }
     
     if (success) {
       success(objectsArray);
     }
     
   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
     NSLog(@"Error: %@", error);
     
     if (failure) {
       failure(error, operation.response.statusCode);
     }
   }];
  
}


#pragma mark - session methods

- (void) postSessionWithID:(NSInteger) topic_id
               onSuccess:(void(^)(QZBSession *session, QZBOpponentBot *bot)) success
               onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
  
  NSDictionary* params =@{@"game_session":@{@"host_id":@(1),@"topic_id":@(topic_id)},@"token":[QZBCurrentUser sharedInstance].user.api_key};
  
  [self.requestOperationManager POST:@"game_sessions"
                          parameters:params
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
    
    NSLog(@"JSON: %@", responseObject);
                               QZBSession *session = [[QZBSession alloc] initWIthDictionary:responseObject];
                               //NSNumber *isOffline = [responseObject objectForKey:@"offline"];
                               QZBOpponentBot *bot = [[QZBOpponentBot alloc] initWithDictionary:responseObject];
                               
                               if(success){
                                 success(session,bot);
                               }

  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"%@, /n %@",operation, error);
    
    if (failure) {
      failure(error, operation.response.statusCode);
    }
    
  }];
  
}

//отправляет данные о ходе пользователя
-(void)PATCHSessionQuestionWithID:(NSInteger)sessionQuestionID
                           answer:(NSInteger)answerID
                             time:(NSInteger)answerTime
                        onSuccess:(void(^)()) success
                        onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure{
  
  NSDictionary *params = @{@"game_session_question": @{ @"host_answer_id":@(answerID) , @"host_time": @(answerTime)},@"token":[QZBCurrentUser sharedInstance].user.api_key};
  
  NSString *URLString = [NSString stringWithFormat:@"game_session_questions/%ld",sessionQuestionID ];
  
  [self.requestOperationManager PATCH:URLString
                           parameters:params
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                
    NSLog(@"patched");
                                
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    
    NSLog(@"%@", error);
    
  }];
}


#pragma mark - user registration

-(NSString *)hashPassword:(NSString *)password{
  
  
  
 // NSString *salt = [JFBCrypt generateSaltWithNumberOfRounds:(SInt32)10];
 // NSString *hashedPassword = [JFBCrypt hashPassword:password withSalt:salt];
  
  return [password MD5];
  
}

-(void)POSTRegistrationUser:(NSString *)userName
                      email:(NSString *)userEmail
                   password:(NSString *)password
                        onSuccess:(void(^)(QZBUser *user)) success
                  onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure{
  
  
  NSString *hashedPassword = [self hashPassword:password];
  
  NSLog(@"hashed %@", hashedPassword);
  
  NSDictionary *params = @{@"player":@{@"name":userName,
                                       @"email":userEmail,
                                       @"password_digest":hashedPassword}};
  
  [self.requestOperationManager POST:@"players"
                          parameters:params
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSLog(@"%@", responseObject);
    
    QZBUser *user = [[QZBUser alloc] initWithDict:responseObject];
    
    if (success) {
      success(user);
    }

  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    
    
    if(failure){
      failure(error, operation.response.statusCode);
    }
    NSLog(@"%@", error);
  }];
  
}

-(void)POSTLoginUserEmail:(NSString *)email
                 password:(NSString *)password
                onSuccess:(void(^)(QZBUser *user)) success
                onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure{
  
  NSString *hashedPassword = [self hashPassword:password];
  
  
  
  NSLog(@"email %@ password %@", email, hashedPassword);

 // email = @"foo@bar.com";

 // hashedPassword = @"$2a$10$qfOWhGZO92uXKTjYzzb/9efimcojZOHrTEe0NQPuXVKWljZ1N1mfy";

  
  NSDictionary *params = @{@"email":email,
                           @"password_digest":hashedPassword};
  
  
  
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
                               
                               if(![responseObject objectForKey:@"error"]){
                               
                              NSString *name = [responseObject objectForKey:@"name"];
                                 
                               NSDictionary *dict = @{@"api_key":token, @"name":name,@"email":email };//redo name
                               
                                 QZBUser *user = [[QZBUser alloc] initWithDict:dict];
                                 
                                 if(success){
                                   success(user);
                                 }
                               }
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"%@",error);
    if(failure){
      failure(error, operation.response.statusCode);
    }
    
  }];
}

@end
