//
//  QZBFriendsChooserRoomsController.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 16/07/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBFriendsTVC.h"

@interface QZBFriendsChooserRoomsController : QZBFriendsTVC

- (void)setFriendsOwner:(id<QZBUserProtocol>)user
             andFriends:(NSArray *)friends
           inRoomWithID:(NSNumber *)roomID;

@end
