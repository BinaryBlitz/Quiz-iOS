//
//  QZBFriendInHorizontalTabelViewCell.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 22/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBFriendInHorizontalTabelViewCell.h"
#import "UIImageView+AFNetworking.h"

@implementation QZBFriendInHorizontalTabelViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    //  CGAffineTransform transform = CGAffineTransformMakeRotation(-1.5707963);

    // self.transform = CGAffineTransformMakeRotation(1.5707963);
    self.userName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    self.userName.textAlignment = NSTextAlignmentCenter;
    self.userName.transform = CGAffineTransformMakeRotation(1.5707963);
    self.userName.frame = CGRectMake(10, 0, 20, 100);

    // self.userName.autoresizingMask = UIViewAutoresizingFlexibleWidth |  UIViewAutoresizingFlexibleHeight;
    self.friendUserPic = [[UIImageView alloc] initWithFrame:CGRectMake(40, 10, 80, 80)];
    self.friendUserPic.layer.cornerRadius = self.friendUserPic.bounds.size.height / 2;
    self.friendUserPic.clipsToBounds = YES;
    self.friendUserPic.transform = CGAffineTransformMakeRotation(1.5707963);
    // self.friendUserPic.autoresizingMask = UIViewAutoresizingFlexibleWidth |  UIViewAutoresizingFlexibleHeight;

    [self addSubview:self.userName];
    [self addSubview:self.friendUserPic];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setName:(NSString *)name userpicURLAsString:(NSString *)URLString {
    self.userName.text = name;

    NSURL *url = [NSURL URLWithString:URLString];

    [self.friendUserPic setImageWithURL:url];
}

- (NSString *)reuseIdentifier {
    return @"friendInHorizontalTableView";
}

@end
