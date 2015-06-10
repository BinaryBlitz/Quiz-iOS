//
//  QZBFirstMessageCell.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 09/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBFirstMessageCell.h"
#import "QZBAnotherUserWithLastMessages.h"

@implementation QZBFirstMessageCell

-(void)awakeFromNib{
    
    
}


-(void)setCellWithUserWithLastMessage:(QZBAnotherUserWithLastMessages *)userAndMessage{
    [super setCellWithUser:userAndMessage.user];
    
    self.firstMessageLabel.text = userAndMessage.lastMessage;
    
    
    
}

@end
