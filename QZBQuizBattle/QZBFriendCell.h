//
//  QZBFriendCell.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 05/03/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "QZBAnotherUser.h"

@class QZBAnotherUser;
@interface QZBFriendCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userpicImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property(strong, nonatomic, readonly) QZBAnotherUser *user;

-(void)setCellWithUser:(QZBAnotherUser *)user;

@end
