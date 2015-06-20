//
//  QZBUserInRoomCell.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 16/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBUserInRoomCell.h"
#import "QZBUserWithTopic.h"
#import "QZBGameTopic.h"
#import <DFImageView.h>

@implementation QZBUserInRoomCell

- (void)configureCellWithUserWithTopic:(QZBUserWithTopic *)userWithTopic {
    
    self.usernameLabel.text = userWithTopic.user.name;
    self.topicNameLabel.text = userWithTopic.topic.name;
    self.numberOfUserInRoomLabel.text = @"";
    
    if(userWithTopic.user.imageURL){
        self.userPicImageView.allowsAnimations = YES;
        
        [self.userPicImageView prepareForReuse];
        
        
        [self.userPicImageView setImageWithResource:userWithTopic.user.imageURL];
        
    }else{
        [self.userPicImageView setImage:[UIImage imageNamed:@"userpicStandart"]];
    }
    
}

@end
