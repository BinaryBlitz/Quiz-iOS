#import "QZBCurrentUser.h"
#import "QZBServerManager.h"
#import <Crashlytics/Crashlytics.h>
#import <DDLog.h>

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

static NSString *QZBNeedStartMessager = @"QZBNeedStartMessager";

//#import "QZBUser.h"

@interface QZBCurrentUser ()

@property (strong, nonatomic) QZBUser *user;
@property (strong, nonatomic) NSString *pushToken;
@property (strong, nonatomic) NSData *pushTokenData;

@property (assign, nonatomic) BOOL needStartMessager;

@property (assign, nonatomic) BOOL pushTokenNew;

@end

@implementation QZBCurrentUser

+ (instancetype)sharedInstance {
  static QZBCurrentUser *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[QZBCurrentUser alloc] init];
  });
  return sharedInstance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    // self.pushToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"APNStoken"];
  }
  return self;
}

- (void)setUser:(QZBUser *)user {
  if (user) {
    _user = user;

    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:user];

    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"currentUser"];

    [[Crashlytics sharedInstance] setUserIdentifier:[NSString
        stringWithFormat:@"%@", user.userID]];
    [[Crashlytics sharedInstance] setUserName:user.name];
    if (user.email) {
      [[Crashlytics sharedInstance] setUserEmail:user.email];
    }

    if (self.pushToken) {
      [[QZBServerManager sharedManager] PATCHAPNsToken:self.pushToken];
    }
  }
}

- (void)setAPNsToken:(NSData *)pushTokenData {

  self.pushTokenData = pushTokenData;
  NSString *pushToken = [pushTokenData description];
  pushToken = [pushToken
      stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
  pushToken = [pushToken stringByReplacingOccurrencesOfString:@" " withString:@""];

  if (!self.pushToken) {

    self.pushToken = pushToken;
    DDLogVerbose(@"push token %@", pushToken);

    if (self.user) {
      [[QZBServerManager sharedManager] PATCHAPNsToken:pushToken];
    }
  } else if (![pushToken isEqualToString:self.pushToken]) {

    [[QZBServerManager sharedManager] PATCHAPNsToken:pushToken];
  } else {
    return;
  }

  [[NSUserDefaults standardUserDefaults] setObject:pushToken forKey:@"APNStoken"];
  [[NSUserDefaults standardUserDefaults] synchronize];  //?

  DDLogVerbose(@"push token setted %@", self.pushToken);
}

- (void)userLogOut {
  if (self.pushToken) {
    [[QZBServerManager sharedManager] PATCHAPNsToken:nil];
  }
  self.user = nil;

  [[NSUserDefaults standardUserDefaults] setBool:NO forKey:QZBNeedStartMessager];
  [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"currentUser"];
}

- (BOOL)checkUser {
  if ([[NSUserDefaults standardUserDefaults] objectForKey:@"currentUser"]) {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUser"];
    self.user = [NSKeyedUnarchiver unarchiveObjectWithData:data];

    [self.user updateUserFromServer];

    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"APNStoken"]) {
      self.pushToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"APNStoken"];
    }

    return YES;
  } else {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"APNStoken"]) {
      //если нет пользователя, но есть токен. Токен необходимо удалить с сервера.


    }

    return NO;
  }
}

- (void)setNeedStartMessager:(BOOL)needStartMessager {
  [[NSUserDefaults standardUserDefaults] setBool:needStartMessager forKey:QZBNeedStartMessager];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)needStartMessager {
  return [[NSUserDefaults standardUserDefaults] boolForKey:QZBNeedStartMessager];
}


@end
