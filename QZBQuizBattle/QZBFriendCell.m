//
//  QZBFriendCell.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 05/03/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBFriendCell.h"
#import "QZBAnotherUser.h"
#import "UIImageView+AFNetworking.h"
#import "UIFont+QZBCustomFont.h"
@interface QZBFriendCell ()

@property(strong, nonatomic) QZBAnotherUser *user;

@end

@implementation QZBFriendCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


-(void)setCellWithUser:(QZBAnotherUser *)user{
    
    self.user = user;
    
    self.nameLabel.text = user.name;
    
    if(user.imageURL){
        [self.userpicImageView setImageWithURL:user.imageURL];
    }else{
        [self.userpicImageView setImage:[UIImage imageNamed:@"userpicStandart"]];
    }
    
    if(!user.isViewed){
        self.nameLabel.font = [UIFont boldMuseoFontOfSize:17.0];
    }else{
        self.nameLabel.font = [UIFont museoFontOfSize:17.0];
    }

}



@end
