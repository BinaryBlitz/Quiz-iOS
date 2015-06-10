//
//  QZBAnotherUserWithLastMessages.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 10/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBAnotherUserWithLastMessages.h"
#import "QZBAnotherUser.h"

@implementation QZBAnotherUserWithLastMessages

- (instancetype)initWithUser:(QZBAnotherUser *)user lastMessage:(NSString *)message lastMesageDate:(NSDate *)timestamp
{
    self = [super init];
    if (self) {
        self.user = user;
        self.lastMessage = message;
    }
    return self;
}

@end
