//
//  QZBRoomCell.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 16/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRoomCell.h"
#import "QZBRoom.h"
#import "UIFont+QZBCustomFont.h"

@implementation QZBRoomCell

- (void)configureCellWithRoom:(QZBRoom *)room {
    
//    self.roomIDLabel.text = [NSString stringWithFormat:@"%@",room.roomID];
//    
////    NSMutableString *descr =
//    
//    self.descriptionLabel.text = [room participantsDescription];
//    self.topicsDescriptionLabel.text = [room topicsDescription];
    
    
    NSMutableArray *usersWithTopics = room.participants;
    
    for (int i = 0; i < usersWithTopics.count; i++) {
        
        if(i >= usersWithTopics.count){
            return;
        }
        QZBUserWithTopic *userWithTopic = usersWithTopics[i];
        
        UILabel *label = self.usersDescriptionsLabels[i];
        
        label.attributedText = [room descriptionForUserWithTopic:userWithTopic];
        
    }
    
    self.usersCountLabel.attributedText = [self usersCountAtrtStringFromRoom:room];
    
    
}

- (NSAttributedString *)usersCountAtrtStringFromRoom:(QZBRoom *)room {
    NSInteger count = room.participants.count;
    NSString *currentCount = [NSString stringWithFormat:@"%ld",count];
    NSString *maxCountString = [NSString stringWithFormat:@"%@",room.maxUserCount];
    NSMutableAttributedString *slashString = [[NSMutableAttributedString alloc]
                                              initWithString:@"/"];
    
    NSMutableAttributedString *atrStr = [[NSMutableAttributedString alloc] initWithString:currentCount];
    
    NSMutableAttributedString *maxCountAttrString = [[NSMutableAttributedString alloc] initWithString:maxCountString];
    
    UIFont *museoFontBig = [UIFont museoFontOfSize:30];
    UIFont *museoFontSmall = [UIFont museoFontOfSize:20];
    
    NSRange r = NSMakeRange(0, 1);
    
    [atrStr addAttribute:NSFontAttributeName
                   value:museoFontBig
                   range:r];
    
    [slashString addAttribute:NSFontAttributeName
                        value:museoFontSmall
                        range:r];
    
    [maxCountAttrString addAttribute:NSFontAttributeName
                               value:museoFontSmall
                               range:r];
    
    
    [atrStr appendAttributedString:slashString];
    [atrStr appendAttributedString:maxCountAttrString];
    
    return [[NSAttributedString alloc] initWithAttributedString:atrStr];
    
    
}

@end
