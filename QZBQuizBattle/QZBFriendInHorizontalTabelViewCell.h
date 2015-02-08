//
//  QZBFriendInHorizontalTabelViewCell.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 22/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QZBFriendInHorizontalTabelViewCell : UITableViewCell

@property (strong, nonatomic) UIImageView *friendUserPic;
@property (strong, nonatomic) UILabel *userName;

- (void)setName:(NSString *)name userpicURLAsString:(NSString *)URLString;

@end
