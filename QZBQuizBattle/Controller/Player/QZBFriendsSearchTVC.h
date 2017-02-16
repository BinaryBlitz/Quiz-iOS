//
//  QZBFriendsSearchTVC.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 11/03/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBFriendsTVC.h"

@interface QZBFriendsSearchTVC : QZBFriendsTVC <UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end
