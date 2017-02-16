//
//  QZBMessagerManager.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 04/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QZBUserProtocol.h"

UIKIT_EXTERN NSString *const QZBMessageRecievedNotificationIdentifier;

@class JSQMessage;
@class QZBMessagerManager;             //define class, so protocol can see MyClass
@protocol QZBMessagerManagerDelegate <NSObject>   //define delegate protocol

-(void)didRecieveMessageFrom:(NSString *)bareJid text:(NSString *)text;
//define delegate method to be implemented within another class
@end //end protocol


@interface QZBMessagerManager : NSObject

@property (nonatomic, weak) id <QZBMessagerManagerDelegate> delegate;
@property(assign, nonatomic, readonly) BOOL isConnected;


+ (instancetype)sharedInstance;

- (void)setupStream;
- (void)teardownStream;

- (BOOL)connect;
- (void)disconnect;

-(void)sendMessage:(NSString *)messageStr toUser:(id<QZBUserProtocol>)user;

-(NSMutableArray *)generateJSQMessagesForUser:(id<QZBUserProtocol>)user;


-(NSString *)jidAsStringFromUser:(id<QZBUserProtocol>)user;

-(NSArray *)usersInStorage;

-(NSInteger)countOfUnreaded;

-(void)clearHistory;//dangerous


@end