

#import "QZBLayerMessagerManager.h"
#import <LayerKit/LayerKit.h>
#import "QZBCurrentUser.h"
#import "QZBUser.h"
#import "QZBAnotherUserWithLastMessages.h"
#import "QZBAnotherUser.h"
#import "QZBUserWorker.h"

#import "QZBServerManager.h"
#import "AppDelegate.h"

//#import "LQSViewController.h"
//#import "LQSAppDelegate.h"

/**
 Layer App ID from developer.layer.com
 */

#if QZB_PRODUCTION
static NSString *const LQSLayerAppIDString =
@"layer:///apps/production/7523431a-3ba1-11e5-85e6-2d4d7f0072d6";
#else
static NSString *const LQSLayerAppIDString =
@"layer:///apps/staging/75233f64-3ba1-11e5-81a5-2d4d7f0072d6";
#endif

@interface QZBLayerMessagerManager () <LYRClientDelegate>

@property (nonatomic) LYRClient *layerClient;
@property (assign, nonatomic) BOOL isReloaded;

@end

@implementation QZBLayerMessagerManager

+ (instancetype)sharedInstance {
  static QZBLayerMessagerManager *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[QZBLayerMessagerManager alloc] init];
    // Do any other initialisation stuff here
  });
  return sharedInstance;
}

- (instancetype)init {
  self = [super init];
  if (self) {

    NSURL *appID = [NSURL URLWithString:LQSLayerAppIDString];
    self.layerClient = [LYRClient clientWithAppID:appID delegate:self options:nil];
  }
  return self;
}

- (void)connectWithCompletion:(void (^)(BOOL success, NSError *error))completion {
  // Connect to Layer
  // See "Quick Start - Connect" for more details
  // https://developer.layer.com/docs/quick-start/ios#connect
  [self.layerClient connectWithCompletion:^(BOOL success, NSError *error) {
    if (!success) {
      //   NSLog(@"Failed to connect to Layer: %@", error);
    } else {
      NSString *identifier = nil;
      id userID = [QZBCurrentUser sharedInstance].user.userID;
      if ([userID isKindOfClass:[NSNumber class]]) {
        identifier = [userID stringValue];
      } else {
        identifier = (NSString *)userID;
      }
      //[QZBCurrentUser sharedInstance].user.userID;
      [self authenticateLayerWithUserID:identifier
                             completion:^(BOOL success, NSError *error) {
                               if(success) {

                                 [[[self class] sharedInstance] updateConversations];
                                 if(completion){
                                   completion(success, error);
                                 }
                               }

                               NSData *token =
                               [QZBCurrentUser sharedInstance].pushTokenData;
                               [self.layerClient updateRemoteNotificationDeviceToken:token
                                                                               error:nil];

                               if (!success) {
                                 NSLog(
                                       @"Failed Authenticating Layer Client with error:%@",
                                       error);
                               }
                             }];
    }
  }];
}

#pragma mark - Layer Authentication Methods

- (void)authenticateLayerWithUserID:(NSString *)userID
                         completion:(void (^)(BOOL success, NSError *error))completion {
  if (self.layerClient.authenticatedUser.userID) {
    NSLog(@"Layer Authenticated as User %@", self.layerClient.authenticatedUser.userID);


    if (completion)
      completion(YES, nil);
    return;
  }

  // Authenticate with Layer
  // See "Quick Start - Authenticate" for more details
  //   // https://developer.layer.com/docs/quick-start/ios#authenticate

  /*
   * 1. Request an authentication Nonce from Layer
   */
  [self.layerClient requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
    //  NSLog(@"nonce %@", nonce);
    if (!nonce) {
      if (completion) {
        completion(NO, error);
      }
      return;
    }

    /*
     * 2. Acquire identity Token from Layer Identity Service
     */
    [self
     requestIdentityTokenForUserID:userID
     appID:[self.layerClient.appID absoluteString]
     nonce:nonce
     completion:^(NSString *identityToken, NSError *error) {
       if (!identityToken) {
         if (completion) {
           completion(NO, error);
         }
         return;
       }

       /*
        * 3. Submit identity token to Layer for validation
        */
       //       [self.layerClient authenticateWithIdentityToken:identityToken completion:^(NSString *authenticatedUserID, NSError *error) {
       //          if (authenticatedUserID) {
       //            if (completion) {
       //              completion(YES, nil);
       //            }
       //            NSLog(@"Layer Authenticated as User: %@", authenticatedUserID);
       //          } else {
       //            completion(NO, error);
       //          }
       //        }];
       [self.layerClient authenticateWithIdentityToken:identityToken completion:^(LYRIdentity * _Nullable authenticatedUser, NSError * _Nullable error) {
         if (authenticatedUser.userID) {
           if (completion) {
             completion(YES, nil);
           }
         } else {
           completion(NO, error);
         }
       }];
     }];
  }];
}

- (void)requestIdentityTokenForUserID:(NSString *)userID
                                appID:(NSString *)appID
                                nonce:(NSString *)nonce
                           completion:
(void (^)(NSString *identityToken, NSError *error))completion {
  NSParameterAssert(userID);
  NSParameterAssert(appID);
  NSParameterAssert(nonce);
  NSParameterAssert(completion);

  [[QZBServerManager sharedManager]
   POSTAuthenticateLayerWithNonce:nonce
   callback:^(NSString *token, NSError *error) {
     if (error) {
       completion(nil, error);
       return;
     }

     if (!error) {
       completion(token, nil);
     }
   }];
}

#pragma - mark LYRClientDelegate Delegate Methods

- (void)layerClient:(LYRClient *)client
didReceiveAuthenticationChallengeWithNonce:(NSString *)nonce {
  NSLog(@"Layer Client did recieve authentication challenge with nonce: %@", nonce);
}

- (void)layerClient:(LYRClient *)client didAuthenticateAsUserID:(NSString *)userID {
  NSLog(@"Layer Client did recieve authentication nonce");
}

- (void)layerClientDidDeauthenticate:(LYRClient *)client {
  NSLog(@"Layer Client did deauthenticate");
}

- (void)layerClient:(LYRClient *)client didFinishSynchronizationWithChanges:(NSArray *)changes {
  NSLog(@"Layer Client did finish synchronization");
}

- (void)layerClient:(LYRClient *)client didFailSynchronizationWithError:(NSError *)error {
  NSLog(@"Layer Client did fail synchronization with error: %@", error);
}

- (void)layerClient:(LYRClient *)client
willAttemptToConnect:(NSUInteger)attemptNumber
         afterDelay:(NSTimeInterval)delayInterval
maximumNumberOfAttempts:(NSUInteger)attemptLimit {
  NSLog(@"Layer Client will attempt to connect");
}

- (void)layerClientDidConnect:(LYRClient *)client {
  NSLog(@"Layer Client did connect");
}

- (void)layerClient:(LYRClient *)client didLoseConnectionWithError:(NSError *)error {
  NSLog(@"Layer Client did lose connection with error: %@", error);
}

- (void)layerClientDidDisconnect:(LYRClient *)client {
  NSLog(@"Layer Client did disconnect");
}

#pragma mark - fetch all conversations

- (NSArray *)conversations {

  LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
  NSArray *res = [[self.layerClient executeQuery:query error:nil] array];
  NSMutableArray *arr = [NSMutableArray array];
  for (LYRConversation *c in res) {
    QZBAnotherUserWithLastMessages *userWithLastMessage =
    [[QZBAnotherUserWithLastMessages alloc]
     initWithConversation:c];  //[QZBUserWorker userFromConversation:c];
    [arr addObject:userWithLastMessage];
  }
  NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"lastTimestamp" ascending:NO];

  return [arr sortedArrayUsingDescriptors:@[ sort ]];
}

- (void)updateConversations {
  LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
  NSArray *res = [[self.layerClient executeQuery:query error:nil] array];
  QZBUser *user = [QZBCurrentUser sharedInstance].user;
  for (LYRConversation *c in res) {
    QZBAnotherUserWithLastMessages *userWithLastMessage =
    [[QZBAnotherUserWithLastMessages alloc]
     initWithConversation:c];

    [[QZBServerManager sharedManager] GETPlayerWithID:userWithLastMessage.user.userID
                                            onSuccess:^(QZBAnotherUser *anotherUser) {
                                              [QZBUserWorker saveUser:anotherUser inConversation:c];
                                              [QZBUserWorker saveUser:user inConversation:c];
                                            } onFailure:^(NSError *error, NSInteger statusCode) {

                                            }];
  }
}



- (NSInteger)unreadedCount {
  LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRMessage class]];

  LYRPredicate *unreadPredicate =
  [LYRPredicate predicateWithProperty:@"isUnread"
                    predicateOperator:LYRPredicateOperatorIsEqualTo
                                value:@(YES)];

  // Messages must not be sent by the authenticated user
  LYRPredicate *userPredicate =
  [LYRPredicate predicateWithProperty:@"sender.userID"
                    predicateOperator:LYRPredicateOperatorIsNotEqualTo
                                value:self.layerClient.authenticatedUser.userID];

  query.predicate =
  [LYRCompoundPredicate compoundPredicateWithType:LYRCompoundPredicateTypeAnd
                                    subpredicates:@[ unreadPredicate, userPredicate ]];
  query.resultType = LYRQueryResultTypeCount;
  NSError *error = nil;
  NSUInteger unreadMessageCount = [self.layerClient countForQuery:query error:&error];

  if(error){
    return 0;
  }
  return unreadMessageCount;
}

- (void)deleteConversationLocalyForUser:(QZBAnotherUserWithLastMessages *)user {
  NSString *identifier = nil;

  if([user.user.userID isKindOfClass:[NSString class]]){
    identifier = (NSString *)user.user.userID;//self.friend.userID.stringValue;
  } else {
    identifier = user.user.userID.stringValue;
  }

  LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
  query.predicate = [LYRPredicate predicateWithProperty:@"participants" predicateOperator:LYRPredicateOperatorIsEqualTo
                                                  value:@[ identifier]];
  query.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO] ];

  NSError *error;
  NSOrderedSet *conversations = [self.layerClient executeQuery:query error:&error];

  if (conversations.count <= 0) {
    return;
  }

  if (!error) {
    NSLog(@"%tu conversations with participants %@", conversations.count, @[ identifier ]);
  } else {
    NSLog(@"Query failed with error %@", error);
    return;
  }

  // Retrieve the last conversation
  if (conversations.count) {
    LYRConversation *conversation = [conversations lastObject];
    NSError *error = nil;
    [conversation delete:LYRDeletionModeMyDevices error:&error];
  }

}

- (void)logOut {
  [self.layerClient deauthenticateWithCompletion:^(BOOL success, NSError *error){
    
  }];
}

- (void)logOutWithCompletion:(void (^)(BOOL success, NSError *error))completion {
  [self.layerClient deauthenticateWithCompletion:^(BOOL success, NSError *error) {
    if (completion) {
      completion(success, error);
    }
  }];
}
@end
