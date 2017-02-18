#import "JSQMessagesViewController.h"
#import "QZBUserProtocol.h"

@interface QZBMessengerVC : JSQMessagesViewController //<XMPPStreamDelegate>

- (void)initWithUser:(id <QZBUserProtocol>)user;

@end
