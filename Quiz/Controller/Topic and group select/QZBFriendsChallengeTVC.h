#import "QZBFriendsTVC.h"

@class QZBGameTopic;

@interface QZBFriendsChallengeTVC : QZBFriendsTVC<UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

-(void)setFriendsOwner:(id<QZBUserProtocol>)user andFriends:(NSArray *)friends gameTopic:(QZBGameTopic *)topic;
@end
