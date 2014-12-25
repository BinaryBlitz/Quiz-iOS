//
//  QZBServerManager.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 24/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
@class QZBSession;
@class QZBOpponentBot;
@interface QZBServerManager : NSObject

+ (QZBServerManager*) sharedManager ;


- (void) getTopicsWithID:(NSInteger) ID
               onSuccess:(void(^)(NSArray* topics)) success
               onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

- (void) postSessionWithID:(NSInteger) topic_id
                onSuccess:(void(^)(QZBSession *session, QZBOpponentBot *bot)) success
                onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

@end
