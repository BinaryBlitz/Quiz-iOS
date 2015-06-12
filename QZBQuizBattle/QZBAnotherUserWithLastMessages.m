//
//  QZBAnotherUserWithLastMessages.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 10/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBAnotherUserWithLastMessages.h"
#import "QZBAnotherUser.h"
#import "QZBStoredUser.h"
#import "QZBUserWorker.h"

@interface QZBAnotherUserWithLastMessages()

@property(strong, nonatomic) NSNumber *unreadedCount;
@property(strong, nonatomic) QZBStoredUser *storedUser;

@property(strong, nonatomic) id<QZBUserProtocol> user;
@property(strong, nonatomic) NSString *lastMessage;

@property(strong, nonatomic) QZBUserWorker *userWorker;
@end

@implementation QZBAnotherUserWithLastMessages

//- (instancetype)initWithUser:(QZBAnotherUser *)user lastMessage:(NSString *)message lastMesageDate:(NSDate *)timestamp
//{
//    self = [super init];
//    if (self) {
//        self.user = user;
//        self.lastMessage = message;
//    }
//    return self;
//}


- (instancetype)initWithStoredUser:(QZBStoredUser *)user
                       lastMessage:(NSString *)message
                    lastMesageDate:(NSDate *)timestamp
{
    self = [super init];
    if (self) {
        self.userWorker = [[QZBUserWorker alloc] init];
        self.user = [self.userWorker userFromStoredUser:user];
        self.storedUser = user;
        
        self.lastMessage = message;
        
    }
    return self;
}

-(void)readAllMessages{
    [self.userWorker readAllMessages:self.storedUser];
}

-(NSNumber *)unreadedCount{
    
    return self.storedUser.unreadedCount;
}

@end
