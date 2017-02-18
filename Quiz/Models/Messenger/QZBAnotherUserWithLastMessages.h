#import <Foundation/Foundation.h>
#import "QZBUserProtocol.h"

@class QZBAnotherUser;
//@class QZBStoredUser;
@class LYRConversation;

@interface QZBAnotherUserWithLastMessages : NSObject

@property (strong, nonatomic, readonly) id <QZBUserProtocol> user;
@property (strong, nonatomic, readonly) NSString *lastMessage;
@property (strong, nonatomic, readonly) NSNumber *unreadedCount;
@property (strong, nonatomic, readonly) NSDate *lastTimestamp;
@property (strong, nonatomic, readonly) NSString *sinceNow;


//- (instancetype)initWithUser:(QZBAnotherUser *)user
//                 lastMessage:(NSString *)message
//              lastMesageDate:(NSDate *)timestamp;

//- (instancetype)initWithStoredUser:(QZBStoredUser *)user
//                       lastMessage:(NSString *)message
//                    lastMesageDate:(NSDate *)timestamp;
//
//-(void)readAllMessages;

- (instancetype)initWithConversation:(LYRConversation *)conversation;

@end
