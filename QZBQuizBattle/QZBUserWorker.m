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

#import "CoreData+MagicalRecord.h"


@implementation QZBUserWorker

-(void)userFromStoreUser:(QZBStoredUser *)user callback:(void (^)(QZBAnotherUser *anotherUser))callback{
    
    [[QZBServerManager sharedManager] GETPlayerWithID:user.userID onSuccess:^(QZBAnotherUser *anotherUser) {
        
        if(callback){
            callback(anotherUser);
        }
    } onFailure:^(NSError *error, NSInteger statusCode) {
        if(callback){
            callback(nil);
        }
    }];
}


-(id<QZBUserProtocol>)userFromJid:(NSString *)jidAsString{
    QZBAnotherUser *u = [[QZBAnotherUser alloc] init];

    QZBStoredUser *storedUser = [self userWithJidAsString:jidAsString];
    

    if(!storedUser){
        return nil;
    }else{
        u.name = storedUser.name;
        u.userID = storedUser.userID;
        u.imageURL = [NSURL URLWithString:storedUser.imageURLAsString];
        return u;
    }
    
    
}


-(QZBStoredUser *)userWithJidAsString:(NSString *)jidAsString{
    
    NSNumber *userID = [self idFromJidAsString:jidAsString];
    
    QZBStoredUser *exitingUser = [QZBStoredUser MR_findFirstByAttribute:@"userID" withValue:userID];
    
    return exitingUser;
}


-(NSNumber *)idFromJidAsString:(NSString *)jidAsString{
    jidAsString = [jidAsString substringFromIndex:2];
    
    NSRange r = [jidAsString rangeOfString:@"@"];
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    return [f numberFromString:[jidAsString substringToIndex:r.location]];
    
   // return [jidAsString substringToIndex:r.location];

}


-(QZBStoredUser *)storedUserWithUsername:(NSString *)username
                                  jid:(NSString *)userJid
                                imageURL:(NSString *)imgUrl{
    
    NSNumber *userID = [self idFromJidAsString:userJid];
    
    return [self storedUserWithUsername:username userID:userID imageURL:imgUrl];
}

-(QZBStoredUser *)storedUserWithUsername:(NSString *)username
                                  userID:(NSNumber *)userID
                                imageURL:(NSString *)imgUrl{
    
    QZBStoredUser *exitingUser = [QZBStoredUser MR_findFirstByAttribute:@"userID"
                                                              withValue:userID];
    
    if(!exitingUser){
        exitingUser = [QZBStoredUser MR_createEntity];
        exitingUser.userID = userID;
    }
    exitingUser.name = username;
    exitingUser.imageURLAsString = imgUrl;
    
    return exitingUser;
    
}


+(void)saveUserInMemory:(id<QZBUserProtocol>)user{
    
    QZBStoredUser *exitingUser = [QZBStoredUser MR_findFirstByAttribute:@"userID"
                                                              withValue:user.userID];
    
    if(!exitingUser){
        exitingUser = [QZBStoredUser MR_createEntity];
        exitingUser.userID = user.userID;
    }
    exitingUser.name = user.name;
    exitingUser.imageURLAsString = user.imageURL.absoluteString;
}


-(void)readAllMessages:(QZBStoredUser *)user{
    user.unreadedCount = 0;
}

-(void)addOneUnreadedMessage:(QZBStoredUser *)user{
    NSInteger count = [user.unreadedCount integerValue];
    
    count++;
    
    user.unreadedCount = @(count);
    
}


@end
