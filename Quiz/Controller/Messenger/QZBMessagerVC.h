#import "JSQMessagesViewController.h"
#import "QZBUserProtocol.h"

@interface QZBMessagerVC : JSQMessagesViewController //<XMPPStreamDelegate>

- (void)initWithUser:(id <QZBUserProtocol>)user;

@end
