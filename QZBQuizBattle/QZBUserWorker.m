//
//  QZBUserWorker.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 10/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBUserWorker.h"
#import "QZBStoredUser.h"
#import "QZBAnotherUser.h"
#import "QZBServerManager.h"
#import <LayerKit/LayerKit.h>
#import "QZBCurrentUser.h"

#import "CoreData+MagicalRecord.h"

@implementation QZBUserWorker

- (void)userFromStoreUser:(QZBStoredUser *)user
                 callback:(void (^)(QZBAnotherUser *anotherUser))callback {
    [[QZBServerManager sharedManager] GETPlayerWithID:user.userID
        onSuccess:^(QZBAnotherUser *anotherUser) {

            if (callback) {
                callback(anotherUser);
            }
        }
        onFailure:^(NSError *error, NSInteger statusCode) {
            if (callback) {
                callback(nil);
            }
        }];
}

- (id<QZBUserProtocol>)userFromJid:(NSString *)jidAsString {
    QZBAnotherUser *u = [[QZBAnotherUser alloc] init];

    QZBStoredUser *storedUser = [self userWithJidAsString:jidAsString];

    if (!storedUser) {
        return nil;
    } else {
        u.name = storedUser.name;
        u.userID = storedUser.userID;
        u.imageURL = [NSURL URLWithString:storedUser.imageURLAsString];
        return u;
    }
}

- (QZBStoredUser *)userWithJidAsString:(NSString *)jidAsString {
    NSNumber *userID = [self idFromJidAsString:jidAsString];

    QZBStoredUser *exitingUser = [QZBStoredUser MR_findFirstByAttribute:@"userID" withValue:userID];

    return exitingUser;
}

- (QZBStoredUser *)userWithID:(NSNumber *)userID {
    
    return [QZBStoredUser MR_findFirstByAttribute:@"userID" withValue:userID];
}

- (NSNumber *)idFromJidAsString:(NSString *)jidAsString {
    jidAsString = [jidAsString substringFromIndex:2];

    NSRange r = [jidAsString rangeOfString:@"@"];

    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    return [f numberFromString:[jidAsString substringToIndex:r.location]];
}

- (QZBStoredUser *)storedUserWithUsername:(NSString *)username
                                      jid:(NSString *)userJid
                                 imageURL:(NSString *)imgUrl {
    NSNumber *userID = [self idFromJidAsString:userJid];

    return [self storedUserWithUsername:username userID:userID imageURL:imgUrl];
}

- (QZBStoredUser *)storedUserWithUsername:(NSString *)username
                                   userID:(NSNumber *)userID
                                 imageURL:(NSString *)imgUrl {
    QZBStoredUser *exitingUser = [QZBStoredUser MR_findFirstByAttribute:@"userID" withValue:userID];

    if (!exitingUser) {
        exitingUser = [QZBStoredUser MR_createEntity];
        exitingUser.userID = userID;
    }
    exitingUser.name = username;
    exitingUser.imageURLAsString = imgUrl;

    [MagicalRecord saveUsingCurrentThreadContextWithBlock:nil completion:nil];

    return exitingUser;
}

- (void)saveUserInMemory:(id<QZBUserProtocol>)user {
    //    QZBStoredUser *exitingUser = [QZBStoredUser MR_findFirstByAttribute:@"userID"
    //                                                              withValue:user.userID];
    //
    //    if(!exitingUser){
    //        exitingUser = [QZBStoredUser MR_createEntity];
    //        exitingUser.userID = user.userID;
    //    }
    //    exitingUser.name = user.name;
    //    exitingUser.imageURLAsString = user.imageURL.absoluteString;

    [self storedUserWithUsername:user.name
                          userID:user.userID
                        imageURL:user.imageURL.absoluteString];
}

- (void)readAllMessages:(QZBStoredUser *)user {
    user.unreadedCount = 0;
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:nil completion:nil];
}

- (void)readAllMessagesOfUser:(id<QZBUserProtocol>)user {
    QZBStoredUser *storedUser = [self storedUserWithUsername:user.name
                                                      userID:user.userID
                                                    imageURL:user.imageURL.absoluteString];

    storedUser.unreadedCount = 0;
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:nil completion:nil];
}

- (void)addOneUnreadedMessage:(QZBStoredUser *)user {
    NSInteger count = [user.unreadedCount integerValue];

    count++;

    user.unreadedCount = @(count);

    [MagicalRecord saveUsingCurrentThreadContextWithBlock:nil completion:nil];
}

- (id<QZBUserProtocol>)userFromStoredUser:(QZBStoredUser *)storedUser {
    QZBAnotherUser *user = [[QZBAnotherUser alloc] init];

    user.name = storedUser.name;
    user.userID = storedUser.userID;

    if (storedUser.imageURLAsString && storedUser.imageURLAsString.length > 0) {
        user.imageURL = [NSURL URLWithString:storedUser.imageURLAsString];
    } else {
        user.imageURL = nil;
    }

    return user;
}

- (NSArray *)allUsers {
    return [QZBStoredUser MR_findAll];
}

- (void)deleteAllUsersInStorage {  // QZBStoredUser
    //  NSArray *storedUsers = [QZBStoredUser MR_findAll];

    [QZBStoredUser MR_truncateAll];
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:nil completion:nil];
}

+ (QZBAnotherUser *)userFromConversation:(LYRConversation *)conversation {
    NSDictionary *dict = nil; //conversation.metadata;
    NSNumber *usID = [QZBCurrentUser sharedInstance].user.userID;
    NSString *userIDAsString = nil;
    if([usID isKindOfClass:[NSNumber class]]) {
        userIDAsString = usID.stringValue;
    } else {
        userIDAsString = (NSString *)usID;
    }
    
    for(id key in conversation.metadata) {
        if(![key isEqualToString:userIDAsString]){
            dict = conversation.metadata[key];
            break;
        }
    }
    
    QZBAnotherUser *user = [[QZBAnotherUser alloc] initWithDictionary:dict];
   // NSDictionary *dict =
    
   // user.userID = conversatio
    
    return user;
    
}

+ (void)saveUser:(id<QZBUserProtocol>)user inConversation:(LYRConversation *)conversation {
    NSString *userID = nil;
    if([user.userID isKindOfClass:[NSString class]]) {
        userID = (NSString *)user.userID;
    } else {
        userID = user.userID.stringValue;
    }
    
    [conversation setValue:[[self class] dictForUser:user] forMetadataAtKeyPath:userID];
}

+(NSDictionary *)dictForUser:(id<QZBUserProtocol>)user {
    NSMutableDictionary *tmpDict = [NSMutableDictionary dictionary];
    
    NSString *userID = nil;
    if([user.userID isKindOfClass:[NSString class]]) {
        userID = (NSString *)user.userID;
    } else {
        userID = user.userID.stringValue;
    }
    
    [tmpDict setObject:userID forKey:@"id"];
    [tmpDict setObject:user.name forKey:@"username"];
    
    if(user.imageURL){
        NSString *urlAsString = [user.imageURL.absoluteString stringByReplacingOccurrencesOfString:QZBServerBaseUrl
                                                                                        withString:@""];
        [tmpDict setObject:urlAsString forKey:@"avatar_thumb_url"];
    }
    
    if(user.imageURLBig){
        NSString *urlAsString = [user.imageURLBig.absoluteString stringByReplacingOccurrencesOfString:QZBServerBaseUrl
                                                                                        withString:@""];
        [tmpDict setObject:urlAsString forKey:@"avatar_url"];
    }
    
    return [NSDictionary dictionaryWithDictionary:tmpDict];
}


@end
