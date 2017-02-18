#import <Foundation/Foundation.h>
#import "QZBUserProtocol.h"

//@class QZBStoredUser;
@class LYRConversation;
@class QZBAnotherUser;

@interface QZBUserWorker : NSObject

+ (QZBAnotherUser *)userFromConversation:(LYRConversation *)conversation;

+ (void)saveUser:(id <QZBUserProtocol>)user inConversation:(LYRConversation *)conversation;

+ (NSDictionary *)dictForUser:(id <QZBUserProtocol>)user;

@end
