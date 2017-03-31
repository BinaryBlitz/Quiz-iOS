#define MR_LOGGING_ENABLED 0

#import "AppDelegate.h"
#import "VKSdk.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "MagicalRecord/MagicalRecord.h"
#import "QZBQuizIAPHelper.h"
#import "QZBUser.h"
#import "QZBCurrentUser.h"
#import "QZBPlayerPersonalPageVC.h"
#import "QZBAnotherUser.h"
#import "QZBSessionManager.h"
#import "UIViewController+QZBControllerCategory.h"
#import <DDASLLogger.h>

#import "DDTTYLogger.h"

#import <UAAppReviewManager.h>

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)          application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"QZBQuizBattle"];

  [DDLog addLogger:[DDASLLogger sharedInstance] withLogLevel:LOG_LEVEL_VERBOSE];
  [DDLog addLogger:[DDTTYLogger sharedInstance] withLogLevel:LOG_LEVEL_VERBOSE];

  [UAAppReviewManager setAppID:@"1017347211"];
  [UAAppReviewManager setSignificantEventsUntilPrompt:7];
  [UAAppReviewManager setDaysUntilPrompt:4];
  [UAAppReviewManager setAppName:@"\"1 на 1\""];
  [UAAppReviewManager setCancelButtonTitle:@"Не нравится"];
  [UAAppReviewManager setDebug:NO];

  [Fabric with:@[[Crashlytics class]]];

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
        registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
  }

  UITabBarController *tabController = (UITabBarController *) self.window.rootViewController;
  tabController.selectedIndex = 2;
  NSDictionary *userInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
  if (userInfo) {
    if ([userInfo[@"action"] isEqualToString:@"FRIEND_REQUEST"]) {
      [self showFriendRequestScreenWithDictionary:userInfo];
    } else if ([userInfo[@"action"] isEqualToString:@"CHALLENGE"]) {
      [self acceptChallengeWithDict:userInfo];
    } else if ([userInfo[@"action"] isEqualToString:@"ACHIEVEMENT"]) {
      [self showAchiewvmentWithDict:userInfo];
    } else if ([userInfo[@"action"] isEqualToString:@"ROOM_INVITE"]) {
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

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<NSString *, id> *)options {

  [VKSdk processOpenURL:url
        fromApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]];

  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
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
    DDLogInfo(@"Unresolved error %@, %@", error, [error userInfo]);
  }

  return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
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
      abort();
    }
  }
}

#pragma mark - notifications

- (void)                             application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  [[QZBCurrentUser sharedInstance] setAPNsToken:deviceToken];
}

- (void)         application:(UIApplication *)application
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
    } else if (userInfo[@"layer"] && ![userInfo[@"layer"] isEqual:[NSNull null]]) {
      [self showMessageNotificationWithDictInActiveApp:userInfo];
    }

    [self setBadgeWithDictionary:userInfo];
  }
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

  UITabBarController *tabController = (UITabBarController *) self.window.rootViewController;
  UITabBarItem *tabbarItem = tabController.tabBar.items[vcNum];
  tabbarItem.badgeValue = @"1";
}

- (void)showFriendRequestScreenWithDictionary:(NSDictionary *)dict {
  if (![QZBSessionManager sessionManager].isGoing) {
    UITabBarController *tabController = (UITabBarController *) self.window.rootViewController;

    UINavigationController *navController =
        (UINavigationController *) tabController.viewControllers[1];

    QZBPlayerPersonalPageVC *notificationController =
        (QZBPlayerPersonalPageVC *) [navController.storyboard
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
          (UITabBarController *) self.window.rootViewController;
      UINavigationController *navController =
          (UINavigationController *) tabController.viewControllers[2];
      [navController popToRootViewControllerAnimated:NO];
      tabController.selectedIndex = 2;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"QZBNeedUpdateMainScreen"
                                                        object:nil];
  }
}

- (void)showAchiewvmentWithDict:(NSDictionary *)dict {
  if (![QZBSessionManager sessionManager].isGoing) {
    UITabBarController *tabController = (UITabBarController *) self.window.rootViewController;

    UINavigationController *navController =
        (UINavigationController *) tabController.viewControllers[2];

    QZBPlayerPersonalPageVC *notificationController = navController.viewControllers[0];
    [notificationController showAlertAboutAchievmentWithDict:dict[@"badge"]];
    tabController.selectedIndex = 2;
  }
}

- (void)showRoomsWithDict:(NSDictionary *)dict {
  if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"QZBNeedUpdateMainScreen"
                                                        object:nil];
  }
}

- (void)showMessageNotificationWithDictInActiveApp:(NSDictionary *)userInfo {
  if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
    NSDictionary *d = userInfo[@"aps"];
    NSString *body = @"Новое сообщение";
    if (d[@"alert"] && ![d[@"alert"] isEqual:[NSNull null]] && ![d[@"alert"] isEqual:@""]) {
      body = d[@"alert"];
    } else {
      return;
    }


    NSDictionary *payload = @{@"username": @"", @"message": body};
    [[NSNotificationCenter defaultCenter]
        postNotificationName:@"QZBMessageRecievedNotificationIdentifier"
                      object:payload];
  }
}


@end
