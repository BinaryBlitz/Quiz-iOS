//
//  QZBCurrentUser.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 15/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBCurrentUser.h"
#import "QZBServerManager.h"
#import "QZBMessagerManager.h"
#import <Crashlytics/Crashlytics.h>
#import <DDLog.h>
static const int ddLogLevel = LOG_LEVEL_VERBOSE;

//#import "QZBUser.h"

@interface QZBCurrentUser ()

@property (strong, nonatomic) QZBUser *user;
@property (strong, nonatomic) NSString *pushToken;
//@property(strong, nonatomic) NSString *
@property(assign, nonatomic) BOOL pushTokenNew;

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

        //[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];

        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:user];

        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"currentUser"];
        
        [[Crashlytics sharedInstance] setUserIdentifier:[NSString
                                                         stringWithFormat:@"%@",user.userID]];
        [[Crashlytics sharedInstance] setUserName:user.name];
         if(user.email){
             [[Crashlytics sharedInstance] setUserEmail:user.email];
         }

        if (self.pushToken) {
            [[QZBServerManager sharedManager] POSTAPNsToken:self.pushToken
                onSuccess:^{

                }
                onFailure:^(NSError *error, NSInteger statusCode){

                }];
        }
    }
}

- (void)setAPNsToken:(NSString *)pushToken {
    if (!self.pushToken) {
        self.pushToken = pushToken;
        if (self.user) {
            [[QZBServerManager sharedManager] POSTAPNsToken:pushToken
                onSuccess:^{

                }
                onFailure:^(NSError *error, NSInteger statusCode){

                }];
        }
    }else if (![pushToken isEqualToString:self.pushToken]) {
        
        [[QZBServerManager sharedManager] PATCHAPNsTokenNew:pushToken oldToken:self.pushToken onSuccess:^{
            
        } onFailure:^(NSError *error, NSInteger statusCode) {
            
        }];
        
    } else{
        return;
    }

    [[NSUserDefaults standardUserDefaults] setObject:pushToken forKey:@"APNStoken"];
    [[NSUserDefaults standardUserDefaults] synchronize];  //?

    DDLogVerbose(@"push token setted %@", self.pushToken);
}

- (void)userLogOut {
    // self.user.api_key = nil;

    //[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"APNStoken"];

    if (self.pushToken) {
        [[QZBServerManager sharedManager] DELETEAPNsToken:self.pushToken
            onSuccess:^{
                
            }
            onFailure:^(NSError *error, NSInteger statusCode){

            }];
    }

    //[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"APNStoken"];
    // self.pushToken = nil;
    self.user = nil;
    [[QZBMessagerManager sharedInstance] teardownStream];

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

@end
