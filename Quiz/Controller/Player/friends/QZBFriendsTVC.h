#import <UIKit/UIKit.h>
#import "QZBUserProtocol.h"

@interface QZBFriendsTVC : UITableViewController

- (void)setFriendsOwner:(id <QZBUserProtocol>)user andFriends:(NSArray *)friends;
- (void)setFriendsOwner:(id <QZBUserProtocol>)user
                friends:(NSArray *)friends
        friendsRequests:(NSArray *)friendsRequest;
- (id <QZBUserProtocol>)userAtIndex:(NSUInteger)userIndex;

@end
