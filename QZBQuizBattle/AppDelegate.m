//
//  AppDelegate.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 11/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#define MR_LOGGING_ENABLED 0

#import "AppDelegate.h"
#import "VKSdk.h"
#import "CoreData+MagicalRecord.h"
#import "QZBQuizIAPHelper.h"
#import "QZBQuizTopicIAPHelper.h"
#import "QZBUser.h"
#import "QZBCurrentUser.h"
#import "QZBPlayerPersonalPageVC.h"
#import "QZBAnotherUser.h"
#import "QZBSessionManager.h"
#import "QZBAcceptChallengeVC.h"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [MagicalRecord setupAutoMigratingCoreDataStack];
    //[QZBQuizIAPHelper sharedInstance];

    NSLog(@"launch options %@", launchOptions);
    
    if (IS_OS_8_OR_LATER) {
        [application
            registerUserNotificationSettings:[UIUserNotificationSettings
                                                 settingsForTypes:(UIUserNotificationTypeSound |
                                                                   UIUserNotificationTypeAlert |
                                                                   UIUserNotificationTypeBadge)
                                                       categories:nil]];

        [application registerForRemoteNotifications];

    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeSound)];
    }
    
    
    NSDictionary *userInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if(userInfo) {
        
        if([userInfo[@"action"] isEqualToString:@"FRIEND_REQUEST"]){
            
            [self showFriendRequestScreenWithDictionary:userInfo];
            
        }else if([userInfo[@"action"] isEqualToString:@"CHALLENGE"]){
            
            [self acceptChallengeWithDict:userInfo];

        
        }
    }
    
    
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
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
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
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - notifications

- (void)application:(UIApplication *)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"My token is: %@", deviceToken);
    
    

    //DataModel *dataModel = chatViewController.dataModel;
    //NSString *oldToken = [dataModel deviceToken];
    
    NSString *newToken = [deviceToken description];
    newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"My token is: %@", newToken);
    
    [[QZBCurrentUser sharedInstance] setAPNsToken:newToken];

}

- (void)application:(UIApplication *)application
    didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"Received notification: %@", userInfo);
    
    UIApplicationState state = application.applicationState;
    if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
    {
        if([userInfo[@"action"] isEqualToString:@"FRIEND_REQUEST"]){
        
        [self showFriendRequestScreenWithDictionary:userInfo];
            
        }else if([userInfo[@"action"] isEqualToString:@"CHALLENGE"]){
            
        [self acceptChallengeWithDict:userInfo];
            
        }
    }else{
        
      //  if()
    
    [self setBadgeWithDictionary:userInfo];
    }
   // [self showFriendRequestScreenWithDictionary:userInfo];
}

- (void)application:(UIApplication *)application
    didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Failed to get token, error: %@", error);
    
    
}


-(void)setBadgeWithDictionary:(NSDictionary *)userInfo{
    NSUInteger vcNum = 0;
    
    if([userInfo[@"action"] isEqualToString:@"FRIEND_REQUEST"]){
        
       // [self showFriendRequestScreenWithDictionary:userInfo];
        
        vcNum = 1;
        
    }else if([userInfo[@"action"] isEqualToString:@"CHALLENGE"]){
        
       // [self acceptChallengeWithDict:userInfo];
        vcNum = 2;
    } else{
        return;
    }

    
    UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
    UITabBarItem *tabbarItem = tabController.tabBar.items[vcNum];
    tabbarItem.badgeValue = @"1";
    
    
}

-(void)showFriendRequestScreenWithDictionary:(NSDictionary *)dict{
    
    if(![QZBSessionManager sessionManager].isGoing){
    
    UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
    
    UINavigationController *navController = (UINavigationController *)tabController.viewControllers[1];
    
    QZBPlayerPersonalPageVC *notificationController = (QZBPlayerPersonalPageVC *)[navController.storyboard instantiateViewControllerWithIdentifier:@"friendStoryboardID"];
    
    tabController.selectedIndex = 1;
    
    NSDictionary *player = dict[@"player"];
    
    QZBAnotherUser *user = [[QZBAnotherUser alloc]initWithDictionary:player];
    
    [notificationController initPlayerPageWithUser:user];
    [navController pushViewController:notificationController animated:YES];
    }
    
}


- (void)acceptChallengeWithDict:(NSDictionary *)dict{
    if(![QZBSessionManager sessionManager].isGoing){
        
//        {
//            action = CHALLENGE;
//            aps =     {
//                alert = "Foo challenged you.";
//            };
//            lobby =     {
//                id = 421;
//            };
//        }
//        
        UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
        
        UINavigationController *navController = (UINavigationController *)tabController.viewControllers[2];
        
        QZBAcceptChallengeVC *notificationController = (QZBAcceptChallengeVC *)[navController.storyboard instantiateViewControllerWithIdentifier:@"challengesTVC"];
        
        tabController.selectedIndex = 2;
        
      //  NSDictionary *player = dict[@"player"];
        
      //  QZBAnotherUser *user = [[QZBAnotherUser alloc]initWithDictionary:player];
        
      //  NSDictionary *lobbyDict = dict[@"lobby"];
      //  NSNumber *lobbyID = lobbyDict[@"id"];
        
       // [notificationController initWithLobbyID:lobbyID user:nil];
        
        [navController pushViewController:notificationController animated:YES];
    }
    
    
}

@end
