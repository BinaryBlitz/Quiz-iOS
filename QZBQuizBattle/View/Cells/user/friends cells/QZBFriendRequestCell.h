//
//  QZBFriendRequestCell.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 22/05/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBFriendCell.h"

@interface QZBFriendRequestCell : QZBFriendCell
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *declineButton;

@end
