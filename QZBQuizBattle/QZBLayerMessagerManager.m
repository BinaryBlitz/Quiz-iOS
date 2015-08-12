

#import "QZBLayerMessagerManager.h"
#import <LayerKit/LayerKit.h>
#import "QZBCurrentUser.h"
#import "QZBUser.h"
#import "QZBAnotherUserWithLastMessages.h"
#import "QZBUserWorker.h"

#import "QZBServerManager.h"

//#import "LQSViewController.h"
//#import "LQSAppDelegate.h"

/**
 Layer App ID from developer.layer.com
 */
static NSString *const LQSLayerAppIDString = @"layer:///apps/production/7523431a-3ba1-11e5-85e6-2d4d7f0072d6";

//#if TARGET_IPHONE_SIMULATOR
//// If on simulator set the user ID to Simulator and participant to Device
//NSString *const LQSCurrentUserID = @"Simulator";
//NSString *const LQSParticipantUserID = @"Device";
//NSString *const LQSInitialMessageText = @"Hey Device! This is your friend, Simulator.";
//#else
//// If on device set the user ID to Device and participant to Simulator
//NSString *const LQSCurrentUserID = @"Device";
//NSString *const LQSParticipantUserID = @"Simulator";
//NSString *const LQSInitialMessageText =  @"Hey Simulator! This is your friend, Device.";
//#endif
//NSString *const LQSParticipant2UserID = @"Dashboard";

@interface QZBLayerMessagerManager () <LYRClientDelegate>

@property (nonatomic) LYRClient *layerClient;

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
        self.layerClient = [LYRClient clientWithAppID:appID];
        self.layerClient.delegate = self;

    }
    return self;
}


- (void)connectWithCompletion:(void (^)(BOOL success, NSError * error))completion {
    // Check if Sample App is using a valid app ID.
 //   if([self isValidAppID])
    
        // Add support for shake gesture
      //  application.applicationSupportsShakeToEdit = YES;
        
        //Show a usage the first time the app is launched
      //  [self showFirstTimeMessage];
        
        // Initializes a LYRClient object
//        NSURL *appID = [NSURL URLWithString:LQSLayerAppIDString];
//        self.layerClient = [LYRClient clientWithAppID:appID];
//        self.layerClient.delegate = self;
        //self.layerClient.autodownloadMIMETypes = [NSSet setWithObjects:@"image/png", nil];
        // Connect to Layer
        // See "Quick Start - Connect" for more details
        // https://developer.layer.com/docs/quick-start/ios#connect
        [self.layerClient connectWithCompletion:^(BOOL success, NSError *error) {
            if (!success) {
                NSLog(@"Failed to connect to Layer: %@", error);
            } else {
                
                NSString *identifier =nil;
                id userID = [QZBCurrentUser sharedInstance].user.userID;
                if([userID isKindOfClass:[NSNumber class]]) {
                    identifier = [userID stringValue];
                } else {
                    identifier = (NSString *)userID;
                }
                //[QZBCurrentUser sharedInstance].user.userID;
                [self authenticateLayerWithUserID:identifier completion:^(BOOL success, NSError *error) {
                    
                    NSData *token = [QZBCurrentUser sharedInstance].pushTokenData;
                    [self.layerClient updateRemoteNotificationDeviceToken:token error:nil];
                    
                    if (!success) {
                        NSLog(@"Failed Authenticating Layer Client with error:%@", error);
                    }
                }];
            }
        }];
        
        
        
        // Register for push
      //  [self registerApplicationForPushNotifications:application];
        
    // UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
      // [(LQSViewController *)navigationController.topViewController setLayerClient:self.layerClient];
    
   // return YES;
}

#pragma mark - Push Notification Methods

//- (void)registerApplicationForPushNotifications:(UIApplication *)application
//{
//    // Set up push notifications
//    // For more information about Push, check out:
//    // https://developer.layer.com/docs/ios/guides#push-notification
//    
//    // Checking if app is running iOS 8
//    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
//        // Register device for iOS8
//        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
//        [application registerUserNotificationSettings:notificationSettings];
//        [application registerForRemoteNotifications];
//    } else {
//        // Register device for iOS7
//        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge];
//    }
//}

//- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
//{
//    // Send device token to Layer so Layer can send pushes to this device.
//    // For more information about Push, check out:
//    // https://developer.layer.com/docs/ios/guides#push-notification
//    NSError *error;
//    BOOL success = [self.layerClient updateRemoteNotificationDeviceToken:deviceToken error:&error];
//    if (success) {
//        NSLog(@"Application did register for remote notifications: %@", deviceToken);
//    } else {
//        NSLog(@"Failed updating device token with error: %@", error);
//    }
//}
//
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
//{
//    // Get Message from Metadata
//    __block LYRMessage *message = [self messageFromRemoteNotification:userInfo];
//    
//    NSError *error;
//    BOOL success = [self.layerClient synchronizeWithRemoteNotification:userInfo completion:^(NSArray *changes, NSError *error) {
//        if (changes)
//        {
//            if ([changes count])
//            {
//                message = [self messageFromRemoteNotification:userInfo];
//                completionHandler(UIBackgroundFetchResultNewData);
//            }
//            else
//            {
//                completionHandler(UIBackgroundFetchResultNoData);
//            }
//        }
//        else
//        {
//            completionHandler(UIBackgroundFetchResultFailed);
//        }
//    }];
//    
//    if (success) {
//        NSLog(@"Application did complete remote notification sync");
//    } else {
//        NSLog(@"Failed processing push notification with error: %@", error);
//        completionHandler(UIBackgroundFetchResultNoData);
//    }
//}
//
//- (LYRMessage *)messageFromRemoteNotification:(NSDictionary *)remoteNotification
//{
//    static NSString *const LQSPushMessageIdentifierKeyPath = @"layer.message_identifier";
//    static NSString *const LQSPushAnnouncementIdentifierKeyPath = @"layer.announcement_identifier";
//    
//    // Retrieve message URL from Push Notification
//    NSURL *messageURL = [NSURL URLWithString:[remoteNotification valueForKeyPath:LQSPushMessageIdentifierKeyPath]];
//    
//    if (!messageURL) {
//        messageURL = [NSURL URLWithString:[remoteNotification valueForKeyPath:LQSPushAnnouncementIdentifierKeyPath]];
//    }
//    
//    // Retrieve LYRMessage from Message URL
//    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRMessage class]];
//    query.predicate = [LYRPredicate predicateWithProperty:@"identifier" predicateOperator:LYRPredicateOperatorIsIn value:[NSSet setWithObject:messageURL]];
//    
//    NSError *error;
//    NSOrderedSet *messages = [self.layerClient executeQuery:query error:&error];
//    if (!error) {
//        NSLog(@"Query contains %lu messages", (unsigned long)messages.count);
//        LYRMessage *message= messages.firstObject;
//        LYRMessagePart *messagePart = message.parts[0];
//        NSLog(@"Pushed Message Contents: %@",[[NSString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding]);
//    } else {
//        NSLog(@"Query failed with error %@", error);
//    }
//    
//    return [messages firstObject];
//}

#pragma mark - Layer Authentication Methods

- (void)authenticateLayerWithUserID:(NSString *)userID
                         completion:(void (^)(BOOL success, NSError * error))completion {
    
    if (self.layerClient.authenticatedUserID) {
        NSLog(@"Layer Authenticated as User %@", self.layerClient.authenticatedUserID);
        if (completion) completion(YES, nil);
        return;
    }
    
    // Authenticate with Layer
    // See "Quick Start - Authenticate" for more details
 //   // https://developer.layer.com/docs/quick-start/ios#authenticate
    
    /*
     * 1. Request an authentication Nonce from Layer
     */
    [self.layerClient requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
        NSLog(@"nonce %@", nonce);
        if (!nonce) {
            if (completion) {
                completion(NO, error);
            }
            return;
        }
        
        /*
         * 2. Acquire identity Token from Layer Identity Service
         */
        [self requestIdentityTokenForUserID:userID appID:[self.layerClient.appID absoluteString] nonce:nonce completion:^(NSString *identityToken, NSError *error) {
            if (!identityToken) {
                if (completion) {
                    completion(NO, error);
                }
                return;
            }
            
            /*
             * 3. Submit identity token to Layer for validation
             */
            [self.layerClient authenticateWithIdentityToken:identityToken completion:^(NSString *authenticatedUserID, NSError *error) {
                if (authenticatedUserID) {
                    if (completion) {
                        completion(YES, nil);
                    }
                    NSLog(@"Layer Authenticated as User: %@", authenticatedUserID);
                } else {
                    completion(NO, error);
                }
            }];
        }];
    }];
}

- (void)requestIdentityTokenForUserID:(NSString *)userID appID:(NSString *)appID nonce:(NSString *)nonce completion:(void(^)(NSString *identityToken, NSError *error))completion
{
    NSParameterAssert(userID);
    NSParameterAssert(appID);
    NSParameterAssert(nonce);
    NSParameterAssert(completion);
    
    
//    [[QZBServerManager sharedManager] POSTAuthenticateLayerWithNonce:nonce onSuccess:^(NSString *token) {
//           
//    } onFailure:^(NSError *error, NSInteger statusCode) {
//        
//    }];
    
    [[QZBServerManager sharedManager] POSTAuthenticateLayerWithNonce:nonce
                                                            callback:^(NSString *token, NSError *error) {
                                                                if (error) {
                                                                    
                                                                    completion(nil, error);
                                                                    return;
                                                                }
                                                                
                                                                if(!error){
                                                                    completion(token, nil);
                                                                }
    }];
    
    
//    NSURL *identityTokenURL = [NSURL URLWithString:@"https://layer-identity-provider.herokuapp.com/identity_tokens"];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:identityTokenURL];
//    request.HTTPMethod = @"POST";
//    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    
//    NSDictionary *parameters = @{ @"app_id": appID, @"user_id": userID, @"nonce": nonce };
//    NSData *requestBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
//    request.HTTPBody = requestBody;
//    
//    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
//    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        if (error) {
//            completion(nil, error);
//            return;
//        }
//        
//        // Deserialize the response
//        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//        if(![responseObject valueForKey:@"error"])
//        {
//            NSString *identityToken = responseObject[@"identity_token"];
//            completion(identityToken, nil);
//        }
//        else
//        {
//            NSString *domain = @"layer-identity-provider.herokuapp.com";
//            NSInteger code = [responseObject[@"status"] integerValue];
//            NSDictionary *userInfo =
//            @{
//              NSLocalizedDescriptionKey: @"Layer Identity Provider Returned an Error.",
//              NSLocalizedRecoverySuggestionErrorKey: @"There may be a problem with your APPID."
//              };
//            
//            NSError *error = [[NSError alloc] initWithDomain:domain code:code userInfo:userInfo];
//            completion(nil, error);
//        }
//        
//    }] resume];
}

#pragma - mark LYRClientDelegate Delegate Methods

- (void)layerClient:(LYRClient *)client didReceiveAuthenticationChallengeWithNonce:(NSString *)nonce
{
    NSLog(@"Layer Client did recieve authentication challenge with nonce: %@", nonce);
}

- (void)layerClient:(LYRClient *)client didAuthenticateAsUserID:(NSString *)userID
{
    NSLog(@"Layer Client did recieve authentication nonce");
}

- (void)layerClientDidDeauthenticate:(LYRClient *)client
{
    NSLog(@"Layer Client did deauthenticate");
}

- (void)layerClient:(LYRClient *)client didFinishSynchronizationWithChanges:(NSArray *)changes
{
    NSLog(@"Layer Client did finish synchronization");
}

- (void)layerClient:(LYRClient *)client didFailSynchronizationWithError:(NSError *)error
{
    NSLog(@"Layer Client did fail synchronization with error: %@", error);
}

- (void)layerClient:(LYRClient *)client willAttemptToConnect:(NSUInteger)attemptNumber afterDelay:(NSTimeInterval)delayInterval maximumNumberOfAttempts:(NSUInteger)attemptLimit
{
    NSLog(@"Layer Client will attempt to connect");
}

- (void)layerClientDidConnect:(LYRClient *)client
{
    NSLog(@"Layer Client did connect");
}

- (void)layerClient:(LYRClient *)client didLoseConnectionWithError:(NSError *)error
{
    NSLog(@"Layer Client did lose connection with error: %@", error);
}

- (void)layerClientDidDisconnect:(LYRClient *)client
{
    NSLog(@"Layer Client did disconnect");
}

#pragma mark - sending

//- (void)sendMessage:(NSString *)messageText{
//    
//    // Send a Message
//    // See "Quick Start - Send a Message" for more details
//    // https://developer.layer.com/docs/quick-start/ios#send-a-message
//    
//    LYRMessagePart *messagePart;
//    self.messageImage.image = nil;
//    // If no conversations exist, create a new conversation object with a single participant
//    if (!self.conversation) {
//        [self fetchLayerConversation];
//    }
//    
//    //if we are sending an image
//    if (self.sendingImage) {
//        UIImage *image = self.photo; //get photo
//        NSData *imageData = UIImagePNGRepresentation(image);
//        messagePart = [LYRMessagePart messagePartWithMIMEType:MIMETypeImagePNG data:imageData];
//        self.sendingImage = NO;
//    }else
//    {
//        //Creates a message part with text/plain MIME Type
//        messagePart = [LYRMessagePart messagePartWithText:messageText];
//    }
//    
//    // Creates and returns a new message object with the given conversation and array of message parts
//    NSString *pushMessage= [NSString stringWithFormat:@"%@ says %@",self.layerClient.authenticatedUserID ,messageText];
//    LYRMessage *message = [self.layerClient newMessageWithParts:@[messagePart] options:@{LYRMessageOptionsPushNotificationAlertKey: pushMessage} error:nil];
//    
//    // Sends the specified message
//    NSError *error;
//    BOOL success = [self.conversation sendMessage:message error:&error];
//    if (success) {
//        // If the message was sent by the participant, show the sentAt time and mark the message as read
//        NSLog(@"Message queued to be sent: %@", messageText);
//        self.inputTextView.text = @"";
//        
//    } else {
//        NSLog(@"Message send failed: %@", error);
//    }
//    self.photo = nil;
//    if (!self.queryController) {
//        [self setupQueryController];
//    }
//}

//#pragma mark - First Run Notification
//
//- (void)showFirstTimeMessage;
//{
//    static NSString *const LQSApplicationHasLaunchedOnceDefaultsKey = @"applicationHasLaunchedOnce";
//    
//    if (![[NSUserDefaults standardUserDefaults] boolForKey:LQSApplicationHasLaunchedOnceDefaultsKey]) {
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:LQSApplicationHasLaunchedOnceDefaultsKey];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        
//        // This is the first launch ever
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hello!"
//                                                        message:@"This is a very simple example of a chat app using Layer. Launch this app on a Simulator and a Device to start a 1:1 conversation. If you shake the Device the navbar color will change on both the Simulator and Device."
//                                                       delegate:self
//                                              cancelButtonTitle:nil
//                                              otherButtonTitles:nil];
//        [alert addButtonWithTitle:@"Got It!"];
//        [alert show];
//    }
//}

//#pragma mark - Check if Sample App is using a valid app ID.
//
//- (BOOL) isValidAppID
//{
//    if([LQSLayerAppIDString isEqual: @"LAYER_APP_ID"])
//    {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"\xF0\x9F\x98\xA5"
//                                                        message:@"To correctly use this project you need to replace LAYER_APP_ID in LQSAppDelegate.m (line 16) with your App ID from developer.layer.com."
//                                                       delegate:self
//                                              cancelButtonTitle:nil
//                                              otherButtonTitles:nil];
//        [alert addButtonWithTitle:@"Ok"];
//        [alert show];
//        return NO;
//    }
//    return YES;
//}
//
//- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
//    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Ok"])
//    {
//        abort();
//    }
//}

#pragma mark - fetch all conversations


-(NSArray *)conversations {
    
//    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
//    
//    NSError *error = nil;
//    NSOrderedSet *conversations = [self.client executeQuery:query error:&error];
//    if (conversations) {
//        NSLog(@"%tu conversations", conversations.count);
//    } else {
//        NSLog(@"Query failed with error %@", error);
//    }
//    
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
    
    NSArray *res = [[self.layerClient executeQuery:query error:nil] array];
    
    
    
    
    
    
  //  NSSortDescriptor *firstDescriptot = [NSSortDescriptor alloc] initWithKey:@"" ascending:<#(BOOL)#>
    //NSPredicate *firstPred = [NSPredicate ]
  //  LYRConversation *lastPredicate = [LYRPredicate predicateWithProperty:@"" predicateOperator:<#(LYRPredicateOperator)#> value:<#(id)#>]
    NSMutableArray *arr = [NSMutableArray array];
    for(LYRConversation *c in res){
        QZBAnotherUserWithLastMessages *userWithLastMessage =
        [[QZBAnotherUserWithLastMessages alloc] initWithConversation:c]; //[QZBUserWorker userFromConversation:c];
        [arr addObject:userWithLastMessage];
    }
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"lastTimestamp" ascending:NO];
   // arr = [arr sortedArrayUsingDescriptors:@[sort]];
    
    return [arr sortedArrayUsingDescriptors:@[sort]];
}

-(NSInteger)unreadedCount {
    
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRMessage class]];
    
    // Messages must be unread
    LYRPredicate *unreadPredicate =[LYRPredicate predicateWithProperty:@"isUnread" predicateOperator:LYRPredicateOperatorIsEqualTo value:@(YES)];
    
    // Messages must not be sent by the authenticated user
    LYRPredicate *userPredicate = [LYRPredicate predicateWithProperty:@"sender.userID" predicateOperator:LYRPredicateOperatorIsNotEqualTo value:self.layerClient.authenticatedUserID];
    
    query.predicate = [LYRCompoundPredicate compoundPredicateWithType:LYRCompoundPredicateTypeAnd subpredicates:@[unreadPredicate, userPredicate]];
    query.resultType = LYRQueryResultTypeCount;
    NSError *error = nil;
    NSUInteger unreadMessageCount = [self.layerClient countForQuery:query error:&error];
    
    return unreadMessageCount;
    
}

-(void)logOut {
    [self.layerClient deauthenticateWithCompletion:^(BOOL success, NSError *error) {
        
    }];
    
}

-(void)logOutWithCompletion:(void (^)(BOOL success, NSError *error))completion {
    
    [self.layerClient deauthenticateWithCompletion:^(BOOL success, NSError *error) {
        if(completion){
            completion(success,error);
        }
    }];
}
@end
