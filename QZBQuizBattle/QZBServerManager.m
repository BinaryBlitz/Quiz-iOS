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
#import "QZBOpponentBot.h"

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
  
  
  
  [self.requestOperationManager
   GET:@"categories"
   parameters:nil
   success:^(AFHTTPRequestOperation *operation, NSArray* responseObject) {
     NSLog(@"JSON: %@", responseObject);
     
     //NSArray* dictsArray = [responseObject objectForKey:@"topics"];
     NSLog(@"%@", [responseObject firstObject]);
     
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



- (void) getTopicsWithID:(NSInteger) ID
               onSuccess:(void(^)(NSArray* topics)) success
                    onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
  
  NSDictionary* params =@{@"ID":@(ID)};
  
  
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


- (void) postSessionWithID:(NSInteger) topic_id
               onSuccess:(void(^)(QZBSession *session, QZBOpponentBot *bot)) success
               onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
  
  NSDictionary* params =@{@"session":@{@"host_id":@(1),@"topic_id":@(topic_id)}};
  
  [self.requestOperationManager POST:@"sessions"
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
  }];
  
}
/*
-(void)postUserWithName:(NSString *)name
                  email:(NSString *)email
               password:(NSString *)password
              onSuccess:(void(^)(QZB *)) success
              onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure

*/







@end
