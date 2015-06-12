//
//  QZBAnotherUserWithLastMessages.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 10/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QZBUserProtocol.h"
@class QZBAnotherUser;
@class QZBStoredUser;
@interface QZBAnotherUserWithLastMessages : NSObject
@property(strong, nonatomic, readonly) id<QZBUserProtocol> user;
@property(strong, nonatomic, readonly) NSString *lastMessage;
@property(strong, nonatomic, readonly) NSNumber *unreadedCount;

//- (instancetype)initWithUser:(QZBAnotherUser *)user
//                 lastMessage:(NSString *)message
//              lastMesageDate:(NSDate *)timestamp;

- (instancetype)initWithStoredUser:(QZBStoredUser *)user
                       lastMessage:(NSString *)message
                    lastMesageDate:(NSDate *)timestamp;

-(void)readAllMessages;

@end
