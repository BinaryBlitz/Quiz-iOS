//
//  QZBUserWorker.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 10/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QZBUserProtocol.h"

@class QZBStoredUser;

@interface QZBUserWorker : NSObject

-(id<QZBUserProtocol>)userFromJid:(NSString *)jidAsString;
-(id<QZBUserProtocol>)userFromStoredUser:(QZBStoredUser *)storedUser;

- (QZBStoredUser *)userWithJidAsString:(NSString *)jidAsString;

- (void)saveUserInMemory:(id<QZBUserProtocol>)user;

-(NSNumber *)idFromJidAsString:(NSString *)jidAsString;


-(void)addOneUnreadedMessage:(QZBStoredUser *)user;
-(void)readAllMessages:(QZBStoredUser *)user;


-(QZBStoredUser *)storedUserWithUsername:(NSString *)username
                                     jid:(NSString *)userJid
                                imageURL:(NSString *)imgUrl;


-(NSArray *)allUsers;

@end
