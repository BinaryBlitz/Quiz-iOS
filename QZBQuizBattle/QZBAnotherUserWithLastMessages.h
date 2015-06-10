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
@interface QZBAnotherUserWithLastMessages : NSObject
@property(strong, nonatomic) id<QZBUserProtocol> user;
@property(strong, nonatomic) NSString *lastMessage;

- (instancetype)initWithUser:(QZBAnotherUser *)user
                 lastMessage:(NSString *)message
              lastMesageDate:(NSDate *)timestamp;

@end
