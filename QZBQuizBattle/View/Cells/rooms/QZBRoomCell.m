//
//  QZBRoomCell.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 16/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRoomCell.h"
#import "QZBRoom.h"
#import "QZBUserWithTopic.h"
#import "QZBGameTopic.h"
#import "UIColor+QZBProjectColors.h"
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
    
//    for (int i = 0; i < usersWithTopics.count; i++) {
//        
//        if(i >= usersWithTopics.count){
//            return;
//        }
//        QZBUserWithTopic *userWithTopic = usersWithTopics[i];
//        
//        UILabel *label = self.usersDescriptionsLabels[i];
//        
//        label.attributedText = [room descriptionForUserWithTopic:userWithTopic];
//        
//    }
    
   // QZBUserWithTopic *userWithTopic = usersWithTopics[0];
    for(int i = 0; i < 4; i++){
       // UILabel *label = self.usersDescriptionsLabels[i];
        UILabel *nameLabel = self.namesLabels[i];
        UILabel *topicsLabel = self.topicsNamesLabels[i];
        
        
        if(i < usersWithTopics.count){
            QZBUserWithTopic *userWithTopic = usersWithTopics[i];
          //  label.attributedText = [room descriptionForUserWithTopic:userWithTopic];
            nameLabel.text = userWithTopic.user.name;
            topicsLabel.text = userWithTopic.topic.name;
            
            if([userWithTopic.user respondsToSelector:@selector(isFriend)]){
                
                if(userWithTopic.user.isFriend){
                    nameLabel.textColor = [UIColor ultralightGreenColor];
                } else {
                    nameLabel.textColor = [UIColor whiteColor];
                }
            } else {
                nameLabel.textColor = [UIColor whiteColor];
            }
            
        } else {
           // label.attributedText = nil;
            
            nameLabel.text = nil;
            topicsLabel.text = nil;
        }
    }
    
    self.usersCountLabel.attributedText = [self usersCountAtrtStringFromRoom:room];
    
    
}

- (NSAttributedString *)usersCountAtrtStringFromRoom:(QZBRoom *)room {
    NSInteger count = room.participants.count;
    NSString *currentCount = [NSString stringWithFormat:@"%ld",(long)count];
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
