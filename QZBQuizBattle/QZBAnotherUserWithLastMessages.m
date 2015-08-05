//
//  QZBAnotherUserWithLastMessages.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 10/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBAnotherUserWithLastMessages.h"
#import "QZBAnotherUser.h"
#import "QZBUserWorker.h"
#import <DateTools.h>
#import <LayerKit/LayerKit.h>
#import "QZBLayerMessagerManager.h"

@interface QZBAnotherUserWithLastMessages()

@property(strong, nonatomic) NSNumber *unreadedCount;
@property (strong, nonatomic) LYRConversation *conversation;
@property(strong, nonatomic) NSDate *lastTimestamp;
@property(strong, nonatomic) NSString *sinceNow;

@property(strong, nonatomic) id<QZBUserProtocol> user;
@property(strong, nonatomic) NSString *lastMessage;

@end

@implementation QZBAnotherUserWithLastMessages


- (instancetype)initWithConversation:(LYRConversation *)conversation {
    self = [super init];
    if (self) {
        
     //   self.user = [[QZBAnotherUser alloc] init];
        self.user = [QZBUserWorker userFromConversation:conversation];
        //self.lastMessage = conversation.lastMessage
        LYRMessage *lastMessage = conversation.lastMessage;
        LYRMessagePart *messagePart = lastMessage.parts[0];
        NSString *text = [[NSString alloc]initWithData:messagePart.data
                                              encoding:NSUTF8StringEncoding];
        
        self.lastMessage = text;
        
        self.lastTimestamp = lastMessage.sentAt;
        self.sinceNow = [self.lastTimestamp timeAgoSinceNow];
        self.conversation = conversation;
     //   self.user.name = conversation
        
    }
    return self;
}

//-(void)readAllMessages{
//    [self.userWorker readAllMessages:self.storedUser];
//}

-(NSNumber *)unreadedCount{
    LYRClient *client = [QZBLayerMessagerManager sharedInstance].layerClient;

    
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRMessage class]];
    
    // Messages must be unread
    LYRPredicate *unreadPredicate =[LYRPredicate predicateWithProperty:@"isUnread" predicateOperator:LYRPredicateOperatorIsEqualTo value:@(YES)];
    
    // Messages must not be sent by the authenticated user
    LYRPredicate *userPredicate = [LYRPredicate predicateWithProperty:@"sender.userID" predicateOperator:LYRPredicateOperatorIsNotEqualTo value:client.authenticatedUserID];
    
    LYRPredicate *conversationPredicate = [LYRPredicate predicateWithProperty:@"conversation" predicateOperator:LYRPredicateOperatorIsEqualTo value:self.conversation];
    
    query.predicate = [LYRCompoundPredicate compoundPredicateWithType:LYRCompoundPredicateTypeAnd
                                                        subpredicates:@[unreadPredicate,
                                                                        userPredicate,
                                                                        conversationPredicate]];
    
    query.resultType = LYRQueryResultTypeCount;
    NSError *error = nil;
    NSUInteger unreadMessageCount = [client countForQuery:query error:&error];
    return @((NSInteger)unreadMessageCount);
}

@end
