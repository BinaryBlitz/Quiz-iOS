//
//  AppDelegate.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 11/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//build 1.0.14

#define MR_LOGGING_ENABLED 0

#import "AppDelegate.h"
#import "VKSdk.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "CoreData+MagicalRecord.h"
#import "QZBQuizIAPHelper.h"
#import "QZBQuizTopicIAPHelper.h"
#import "QZBUser.h"
#import "QZBCurrentUser.h"
#import "QZBPlayerPersonalPageVC.h"
#import "QZBAnotherUser.h"
#import "QZBSessionManager.h"
#import "QZBAcceptChallengeVC.h"
#import "QZBRegistrationChooserVC.h"
#import "QZBMainGameScreenTVC.h"
#import "UIViewController+QZBControllerCategory.h"
#import <DDASLLogger.h>
//#import "QZBMessagerManager.h"
#import "QZBMessangerList.h"

#import <LayerKit/LayerKit.h>
//#import "QZBRoomListTVC.h"
//#import <CocoaLumberjack/CocoaLumberjack.h>

#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "DDFileLogger.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface AppDelegate ()

@property (nonatomic) LYRClient *layerClient;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"QZBQuizBattle"];

    //    [DDLog addLogger:[DDASLLogger sharedInstance] withLevel:DDLogLevelInfo];
    //    [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:DDLogLevelInfo];

    [DDLog addLogger:[DDASLLogger sharedInstance] withLogLevel:LOG_LEVEL_VERBOSE];
    [DDLog addLogger:[DDTTYLogger sharedInstance] withLogLevel:LOG_LEVEL_VERBOSE];

    [Fabric with:@[ CrashlyticsKit ]];

    // [self initMessager];

    //   DDLogInfo(@"launch options %@", launchOptions);

    if (IS_OS_8_OR_LATER) {
        [application
            registerUserNotificationSettings:[UIUserNotificationSettings
                                                 settingsForTypes:(UIUserNotificationTypeSound |
                                                                   UIUserNotificationTypeAlert |
                                                                   UIUserNotificationTypeBadge)
                                                       categories:nil]];

        [application registerForRemoteNotifications];

    } else {
        [[UIApplication sharedApplication]
            registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert |
                                                UIRemoteNotificationTypeBadge |
                                                UIRemoteNotificationTypeSound)];
    }

    UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
    tabController.selectedIndex = 2;
    NSDictionary *userInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo) {
        if ([userInfo[@"action"] isEqualToString:@"FRIEND_REQUEST"]) {
            [self showFriendRequestScreenWithDictionary:userInfo];

        } else if ([userInfo[@"action"] isEqualToString:@"CHALLENGE"]) {
            [self acceptChallengeWithDict:userInfo];
        } else if ([userInfo[@"action"] isEqualToString:@"ACHIEVEMENT"]) {
            [self showAchiewvmentWithDict:userInfo];
        } /*else if ([userInfo[@"action"] isEqualToString:@"MESSAGE"]) {
            [self showMessageWithDict:userInfo];
        }*/ else if ([userInfo[@"action"] isEqualToString:@"ROOM_INVITE"]) {
            // ROOM_INVITE
            //  [self showRoomsWithDict:userInfo];
        } else if (userInfo[@"layer"]&& ![userInfo[@"layer"] isEqual:[NSNull null]]) {
            [self showMessageWithDict:userInfo];
        }
    }

    // [self presentRegistration];

    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    [VKSdk processOpenURL:url fromApplication:sourceApplication];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for
    // certain types of
    // temporary interruptions (such as an incoming phone call or SMS message) or when the user
    // quits the application
    // and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame
    // rates. Games should use
    // this method to pause the game.


}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store
    // enough application
    // state information to restore your application to its current state in case it is terminated
    // later.
    // If your application supports background execution, this method is called instead of
    // applicationWillTerminate:
    // when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo
    // many of the changes
    // made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive.
    // If the application
    // was previously in the background, optionally refresh the user interface.

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also
    // applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
 

    [MagicalRecord saveUsingCurrentThreadContextWithBlock:nil completion:nil];
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a
    // directory named
    // "drumih.QZBQuizBattle" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to
    // be able to find and
    // load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"QZBQuizBattle" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return
    // a coordinator,
    // having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    // Create the coordinator and store

    _persistentStoreCoordinator =
        [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL =
        [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"QZBQuizBattle.sqlite"];
    NSError *error = nil;
    NSString *failureReason =
        @"There was an error creating or loading the application's saved data.";

    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:nil
                                                           error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use
        // this function in a
        // shipping application, although it may be useful during development.
        DDLogInfo(@"Unresolved error %@, %@", error, [error userInfo]);
       // abort();
    }

    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the
    // persistent store
    // coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not
            // use this function in
            // a shipping application, although it may be useful during development.
            // DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - notifications

- (void)application:(UIApplication *)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // DDLogInfo(@"My token is: %@", deviceToken);

    // DataModel *dataModel = chatViewController.dataModel;
    // NSString *oldToken = [dataModel deviceToken];

//    NSString *newToken = [deviceToken description];
//    newToken = [newToken
//        stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
//    newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];

    [[QZBCurrentUser sharedInstance] setAPNsToken:deviceToken];
}

- (void)application:(UIApplication *)application
    didReceiveRemoteNotification:(NSDictionary *)userInfo {
    DDLogInfo(@"Received notification: %@", userInfo);

    UIApplicationState state = application.applicationState;
    if (state == UIApplicationStateBackground || state == UIApplicationStateInactive) {
        if ([userInfo[@"action"] isEqualToString:@"FRIEND_REQUEST"]) {
            [self showFriendRequestScreenWithDictionary:userInfo];

        } else if ([userInfo[@"action"] isEqualToString:@"CHALLENGE"]) {
            [self acceptChallengeWithDict:userInfo];
        } else if ([userInfo[@"action"] isEqualToString:@"ACHIEVEMENT"]) {
            [self showAchiewvmentWithDict:userInfo];
        }
    } else {
        if ([userInfo[@"action"] isEqualToString:@"ACHIEVEMENT"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"QZBAchievmentGet"
                                                                object:userInfo];
        } else if ([userInfo[@"action"] isEqualToString:@"CHALLENGE"]) {
            [self acceptChallengeWithDict:userInfo];
        } else if ([userInfo[@"action"] isEqualToString:@"ROOM_INVITE"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"QZBNeedUpdateMainScreen"
                                                                object:nil];
        } else if (userInfo[@"layer"]&& ![userInfo[@"layer"] isEqual:[NSNull null]]) {
            [self showMessageNotificationWithDictInActiveApp:userInfo];
        }

        [self setBadgeWithDictionary:userInfo];
    }
}

- (void)application:(UIApplication *)application
    didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    // DDLogWarn(@"Failed to get token, error: %@", error);
}

- (void)setBadgeWithDictionary:(NSDictionary *)userInfo {
    NSUInteger vcNum = 0;

    if ([userInfo[@"action"] isEqualToString:@"FRIEND_REQUEST"]) {
        vcNum = 1;

    } else if ([userInfo[@"action"] isEqualToString:@"CHALLENGE"]) {
        vcNum = 2;
    } else {
        return;
    }

    UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
    UITabBarItem *tabbarItem = tabController.tabBar.items[vcNum];
    tabbarItem.badgeValue = @"1";
}

- (void)showFriendRequestScreenWithDictionary:(NSDictionary *)dict {
    if (![QZBSessionManager sessionManager].isGoing) {
        UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;

        UINavigationController *navController =
            (UINavigationController *)tabController.viewControllers[1];

        QZBPlayerPersonalPageVC *notificationController =
            (QZBPlayerPersonalPageVC *)[navController.storyboard
                instantiateViewControllerWithIdentifier:@"friendStoryboardID"];

        tabController.selectedIndex = 1;

        NSDictionary *player = dict[@"player"];

        QZBAnotherUser *user = [[QZBAnotherUser alloc] initWithDictionary:player];

        [notificationController initPlayerPageWithUser:user];
        [navController popToRootViewControllerAnimated:NO];
        [navController pushViewController:notificationController animated:YES];
    }
}

- (void)acceptChallengeWithDict:(NSDictionary *)dict {
    if (![QZBSessionManager sessionManager].isGoing) {
        UIApplication *application = [UIApplication sharedApplication];

        UIApplicationState state = application.applicationState;
        if (state == UIApplicationStateBackground || state == UIApplicationStateInactive) {
            UITabBarController *tabController =
                (UITabBarController *)self.window.rootViewController;
            UINavigationController *navController =
                (UINavigationController *)tabController.viewControllers[2];
            [navController popToRootViewControllerAnimated:NO];
            tabController.selectedIndex = 2;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"QZBNeedUpdateMainScreen"
                                                            object:nil];
    }
}

- (void)showAchiewvmentWithDict:(NSDictionary *)dict {
    if (![QZBSessionManager sessionManager].isGoing) {
        UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;

        UINavigationController *navController =
            (UINavigationController *)tabController.viewControllers[2];

        QZBPlayerPersonalPageVC *notificationController = navController.viewControllers[0];
        [notificationController showAlertAboutAchievmentWithDict:dict[@"badge"]];
        tabController.selectedIndex = 2;
    }
}

- (void)showMessageWithDict:(NSDictionary *)dict {
    //    action = MESSAGE;
    //    aps =     {
    //        alert = fdfdf;
    //    };
    //    message =     {
    //        content = fdfdf;
    //        "created_at" = "2015-07-15T14:45:31.964Z";
    //        "creator_id" = 7;
    //        id = 8;
    //        "player_id" = 64;
    //        "updated_at" = "2015-07-15T14:45:31.964Z";
    //    };
    UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
    tabController.selectedIndex = 1;

    UINavigationController *nav = tabController.viewControllers[1];

    [nav popToRootViewControllerAnimated:NO];
    QZBMessangerList *messList =
        [nav.storyboard instantiateViewControllerWithIdentifier:@"messagerList"];

    [nav pushViewController:messList animated:YES];
}

- (void)showRoomsWithDict:(NSDictionary *)dict {
    // roomListTWCIdentifier

    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"QZBNeedUpdateMainScreen"
                                                            object:nil];
    }
}

- (void)showMessageNotificationWithDictInActiveApp:(NSDictionary *)userInfo {
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        NSDictionary *d = userInfo[@"aps"];
        NSString *body = d[@"alert"];
//        NSDictionary *p = userInfo[@"player"];
//        NSString *username = p[@"username"];  // userInfo[@""];
//        NSString *body = d[@"content"];
//        
//        body = userInfo[]
        NSDictionary *payload = @{ @"username" : @"", @"message" : body };
        [[NSNotificationCenter defaultCenter]
            postNotificationName:@"QZBMessageRecievedNotificationIdentifier"
                          object:payload];
    }
}

#pragma mark - layer messager

- (void)connectLayer {
    NSURL *appID =
        [NSURL URLWithString:@"layer:///apps/staging/cadc0b56-39cc-11e5-a089-fdeb71057991"];
    self.layerClient = [LYRClient clientWithAppID:appID];
    [self.layerClient connectWithCompletion:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"Failed to connect to Layer: %@", error);
        } else {
            // For the purposes of this Quick Start project, let's authenticate as a user named
            // 'Device'.  Alternatively, you can authenticate as a user named 'Simulator' if you're
            // running on a Simulator.
            NSString *userIDString = @"Device";
            // Once connected, authenticate user.
            // Check Authenticate step for authenticateLayerWithUserID source
            [self authenticateLayerWithUserID:userIDString
                                   completion:^(BOOL success, NSError *error) {
                                       if (!success) {
                                           NSLog(
                                               @"Failed Authenticating Layer Client with error:%@",
                                               error);
                                       }
                                   }];
        }
    }];
}

- (void)authenticateLayerWithUserID:(NSString *)userID
                         completion:(void (^)(BOOL success, NSError *error))completion {
    // Check to see if the layerClient is already authenticated.
    if (self.layerClient.authenticatedUserID) {
        // If the layerClient is authenticated with the requested userID, complete the
        // authentication process.
        if ([self.layerClient.authenticatedUserID isEqualToString:userID]) {
            NSLog(@"Layer Authenticated as User %@", self.layerClient.authenticatedUserID);
            if (completion)
                completion(YES, nil);
            return;
        } else {
            // If the authenticated userID is different, then deauthenticate the current client and
            // re-authenticate with the new userID.
            [self.layerClient deauthenticateWithCompletion:^(BOOL success, NSError *error) {
                if (!error) {
                    [self authenticationTokenWithUserId:userID
                                             completion:^(BOOL success, NSError *error) {
                                                 if (completion) {
                                                     completion(success, error);
                                                 }
                                             }];
                } else {
                    if (completion) {
                        completion(NO, error);
                    }
                }
            }];
        }
    } else {
        // If the layerClient isn't already authenticated, then authenticate.
        [self authenticationTokenWithUserId:userID
                                 completion:^(BOOL success, NSError *error) {
                                     if (completion) {
                                         completion(success, error);
                                     }
                                 }];
    }
}

- (void)authenticationTokenWithUserId:(NSString *)userID
                           completion:(void (^)(BOOL success, NSError *error))completion {
    /*
     * 1. Request an authentication Nonce from Layer
     */
    [self.layerClient requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
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
                                   [self.layerClient
                                       authenticateWithIdentityToken:
                                           identityToken completion:^(NSString *authenticatedUserID,
                                                                      NSError *error) {
                                           if (authenticatedUserID) {
                                               if (completion) {
                                                   completion(YES, nil);
                                               }
                                               NSLog(@"Layer Authenticated as User: %@",
                                                     authenticatedUserID);
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

    NSURL *identityTokenURL =
        [NSURL URLWithString:@"https://layer-identity-provider.herokuapp.com/identity_tokens"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:identityTokenURL];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    NSDictionary *parameters = @{ @"app_id" : appID, @"user_id" : userID, @"nonce" : nonce };
    NSData *requestBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    request.HTTPBody = requestBody;

    NSURLSessionConfiguration *sessionConfiguration =
        [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    if (error) {
                        completion(nil, error);
                        return;
                    }

                    // Deserialize the response
                    NSDictionary *responseObject =
                        [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    if (![responseObject valueForKey:@"error"]) {
                        NSString *identityToken = responseObject[@"identity_token"];
                        completion(identityToken, nil);
                    } else {
                        NSString *domain = @"layer-identity-provider.herokuapp.com";
                        NSInteger code = [responseObject[@"status"] integerValue];
                        NSDictionary *userInfo = @{
                            NSLocalizedDescriptionKey :
                                @"Layer Identity Provider Returned an Error.",
                            NSLocalizedRecoverySuggestionErrorKey :
                                @"There may be a problem with your APPID."
                        };

                        NSError *error =
                            [[NSError alloc] initWithDomain:domain code:code userInfo:userInfo];
                        completion(nil, error);
                    }

                }] resume];
}

@end
