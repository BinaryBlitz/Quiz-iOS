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
        [self.userpicImageView setImage:[UIImage imageNamed:@"icon_register"]];//redo
    }
    
    
    //self.numberInRating.text = [NSString stringWithFormat:@"%ld", (long)user.position];
    
    //self.score.text = [NSString stringWithFormat:@"%ld", (long)user.points];
    
    //  NSURL *url = [NSURL URLWithString:self.urlString];
    
    // [self.userpic setImageWithURL:url];
    
}



@end
