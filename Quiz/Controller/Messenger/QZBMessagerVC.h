#import "JSQMessagesViewController.h"
#import "QZBUserProtocol.h"

@interface QZBMessagerVC : JSQMessagesViewController //<XMPPStreamDelegate>

- (void)initWithUser:(id <QZBUserProtocol>)user;

//-(void)initWithUser:(id<QZBUserProtocol>)user userpic:(UIImage *)image;

@end
