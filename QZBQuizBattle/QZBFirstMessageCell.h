//
//  QZBFirstMessageCell.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 09/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBFriendCell.h"
@class QZBAnotherUserWithLastMessages;

@interface QZBFirstMessageCell : QZBFriendCell
@property (weak, nonatomic) IBOutlet UILabel *firstMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

-(void)setCellWithUserWithLastMessage:(QZBAnotherUserWithLastMessages *)userAndMessage;


@end
