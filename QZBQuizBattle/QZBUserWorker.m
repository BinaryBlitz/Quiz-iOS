//
//  QZBUserWorker.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 10/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBUserWorker.h"

#import "QZBAnotherUser.h"
#import "QZBServerManager.h"
#import <LayerKit/LayerKit.h>
#import "QZBCurrentUser.h"

#import "CoreData+MagicalRecord.h"

@implementation QZBUserWorker



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
