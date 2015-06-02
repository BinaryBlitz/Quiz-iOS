//
//  QZBFriendRequestManager.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 21/05/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBFriendRequestManager.h"
#import "QZBServerManager.h"
#import "QZBFriendRequest.h"
NSString *const QZBFriendRequestUpdated = @"QZBFriendRequestUpdated";


@interface QZBFriendRequestManager()

@property(strong, nonatomic) NSMutableArray *incoming;
@property(strong, nonatomic) NSMutableArray *outgoing;

@end
@implementation QZBFriendRequestManager
+ (instancetype)sharedInstance {
    static QZBFriendRequestManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[QZBFriendRequestManager alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

-(void)updateRequests{
    [[QZBServerManager sharedManager] GETFriendsRequestsOnSuccess:^(NSArray *incoming, NSArray *outgoing) {
        
        self.incoming = [incoming mutableCopy];
        self.outgoing = [outgoing mutableCopy];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:QZBFriendRequestUpdated object:nil];
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
    }];
    
}

#pragma mark - actions

-(void)acceptForUser:(id<QZBUserProtocol>)user callback:(void (^)(BOOL succes))callback{
    
    QZBFriendRequest *friendRequest = [self findIncomingUser:user];
    if(friendRequest){
        [[QZBServerManager sharedManager] PATCHAcceptFriendRequestWithID:friendRequest.requestID onSuccess:^{
            
            NSLog(@"accepted");
            [self.incoming removeObject:friendRequest];
            if(callback){
                callback(YES);
            }
            
        } onFailure:^(NSError *error, NSInteger statusCode) {
            if(callback){
                callback(NO);
            }
        }];
    }
}

-(void)declineForUser:(id<QZBUserProtocol>)user callback:(void (^)(BOOL succes))callback{
    
    QZBFriendRequest *friendRequest = [self findIncomingUser:user];
    
    [self deleteForFriendRequest:friendRequest callback:callback withAction:^{
        [self.incoming removeObject:friendRequest];
    }];
}

-(void)cancelForUser:(id<QZBUserProtocol>)user callback:(void (^)(BOOL succes))callback{
    
    QZBFriendRequest *friendRequest = [self findOutgoingUser:user];
    
    [self deleteForFriendRequest:friendRequest callback:callback withAction:^{
        [self.outgoing removeObject:friendRequest];
    }];
}



-(void)addFriendUser:(id<QZBUserProtocol>)user callback:(void (^)(BOOL succes))callback{
   
    [[QZBServerManager sharedManager] POSTFriendWithID:user.userID onSuccess:^(QZBFriendRequest *friendRequest) {
        
        friendRequest.userID = user.userID;
        [self.outgoing addObject:friendRequest];
        
        callback(YES);
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        callback(NO);
    }];
    
    
}


#pragma mark - friend state

-(QZBFriendState)friendStateForUser:(id<QZBUserProtocol>)user{
    QZBFriendRequest *friendRequest = nil;
    friendRequest = [self findIncomingUser:user];
    if(friendRequest){
        return QZBFriendStateIncomingRequest;
    }
    friendRequest = [self findOutgoingUser:user];
    if(friendRequest){
        return QZBFriendStateOutcomingRequest;
    }
    return QZBFriendStateNotDefined;
    
    
}

#pragma mark - support methods

-(void)deleteForFriendRequest:(QZBFriendRequest *)friendRequest
                     callback:(void (^)(BOOL succes))callback
                   withAction:(void (^)())action{
    if(friendRequest){
        
        [[QZBServerManager sharedManager] DELETEDeclineFriendRequestWithID:friendRequest.requestID onSuccess:^{
            NSLog(@"decline");
            //[self.incoming removeObject:friendRequest];
            if(action){
                action();
            }
            
            if(callback){
                callback(YES);
            }
        } onFailure:^(NSError *error, NSInteger statusCode) {
            if(callback){
                callback(NO);
            }
        }];
    }else{
        if(callback){
            callback(NO);
        }
    }
    
}

-(QZBFriendRequest *)findIncomingUser:(id<QZBUserProtocol>)user{
    return [self findUser:user InArry:self.incoming];
}

-(QZBFriendRequest *)findOutgoingUser:(id<QZBUserProtocol>)user{
    return [self findUser:user InArry:self.outgoing];
}



-(QZBFriendRequest *)findUser:(id<QZBUserProtocol>)user InArry:(NSMutableArray *)array{
    if([array isEqualToArray:self.incoming] || [array isEqualToArray:self.outgoing]){
    QZBFriendRequest *result = nil;
    for(QZBFriendRequest *friendRequest in array){
        if([user.userID isEqual:friendRequest.userID]){
            result = friendRequest;
            break;
        }
    }
    return result;
    }
    return nil;
}

@end
