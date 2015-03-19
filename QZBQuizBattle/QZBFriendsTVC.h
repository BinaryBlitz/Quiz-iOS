//
//  QZBFriendsTVC.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 24/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QZBUserProtocol.h"

@interface QZBFriendsTVC : UITableViewController

- (void)setFriendsOwner:(id<QZBUserProtocol>)user andFriends:(NSArray *)friends;


- (void)setFriendsOwner:(id<QZBUserProtocol>)user
                friends:(NSArray *)friends
        friendsRequests:(NSArray *)friendsRequest;

-(id<QZBUserProtocol>)userAtIndex:(NSUInteger)userIndex;
//@property (weak, nonatomic) IBOutlet UIBarButtonItem *friendsRequestsButton;

@end
