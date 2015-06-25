//
//  QZBRoomUserResultCell.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 25/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QZBUserWithTopic;

@interface QZBRoomUserResultCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *userPositionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userpicImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userPointsLabel;

-(void)confirureWithUserWithTopic:(QZBUserWithTopic *)userWithTopic position:(NSNumber *)position;

@end
