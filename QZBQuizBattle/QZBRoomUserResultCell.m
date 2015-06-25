//
//  QZBRoomUserResultCell.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 25/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRoomUserResultCell.h"
#import "QZBUserWithTopic.h"
#import <UIImageView+AFNetworking.h>

@implementation QZBRoomUserResultCell

- (void)confirureWithUserWithTopic:(QZBUserWithTopic *)userWithTopic position:(NSNumber *)position {
    self.usernameLabel.text = userWithTopic.user.name;

    self.userPositionLabel.text = [NSString stringWithFormat:@"%@", position];

    self.userPositionLabel.text = [NSString stringWithFormat:@"%@", userWithTopic.points];

    if (userWithTopic.user.imageURL) {
        [self.userpicImageView setImageWithURL:userWithTopic.user.imageURL];
    } else {
        [self.userpicImageView setImage:[UIImage imageNamed:@"userpicStandart"]];
    }
}

@end
