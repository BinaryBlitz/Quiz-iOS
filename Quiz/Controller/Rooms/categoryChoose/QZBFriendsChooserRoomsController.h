#import "QZBFriendsTVC.h"

@interface QZBFriendsChooserRoomsController : QZBFriendsTVC

- (void)setFriendsOwner:(id <QZBUserProtocol>)user
             andFriends:(NSArray *)friends
           inRoomWithID:(NSNumber *)roomID;

@end
