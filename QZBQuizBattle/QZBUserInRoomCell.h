//
//  QZBUserInRoomCell.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 16/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QZBUserWithTopic;
@class DFImageView;


@interface QZBUserInRoomCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfUserInRoomLabel;
@property (weak, nonatomic) IBOutlet UILabel *topicNameLabel;
@property (weak, nonatomic) IBOutlet DFImageView *userPicImageView;

- (void)configureCellWithUserWithTopic:(QZBUserWithTopic *)userWithTopic;

@end
