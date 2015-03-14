//
//  QZBFriendsChallengeTVC.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 13/03/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBFriendsTVC.h"

@class QZBGameTopic;

@interface QZBFriendsChallengeTVC : QZBFriendsTVC

-(void)setFriendsOwner:(id<QZBUserProtocol>)user andFriends:(NSArray *)friends gameTopic:(QZBGameTopic *)topic;
@end
