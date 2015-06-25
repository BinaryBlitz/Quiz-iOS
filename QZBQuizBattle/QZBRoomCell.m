//
//  QZBRoomCell.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 16/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRoomCell.h"
#import "QZBRoom.h"

@implementation QZBRoomCell

- (void)configureCellWithRoom:(QZBRoom *)room {
    
    self.roomIDLabel.text = [NSString stringWithFormat:@"%@",room.roomID];
    
//    NSMutableString *descr =
    
    self.descriptionLabel.text = [room participantsDescription];
    self.topicsDescriptionLabel.text = [room topicsDescription];
}

@end
