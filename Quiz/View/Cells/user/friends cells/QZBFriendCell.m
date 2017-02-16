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
#import "UIColor+QZBProjectColors.h"
@interface QZBFriendCell ()

@property(strong, nonatomic) QZBAnotherUser *user;

@end

@implementation QZBFriendCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


-(void)setCellWithUser:(id<QZBUserProtocol>)user{
    
    self.user = user;
    
    self.nameLabel.text = user.name;
    
//    if(user.imageURL){
//        [self.userpicImageView setImageWithURL:user.imageURL
//                              placeholderImage:[UIImage imageNamed:@"userpicStandart"]];
//    }else{
//        [self.userpicImageView setImage:[UIImage imageNamed:@"userpicStandart"]];
//    }
    
    if([self.user respondsToSelector:@selector(isOnline)]) {
        
        if(self.user.isOnline){
            self.userpicImageView.layer.borderColor = [UIColor lightBlueColor].CGColor;
            self.userpicImageView.layer.borderWidth = 2.0;
        } else {
            self.userpicImageView.layer.borderColor = [UIColor clearColor].CGColor;
            self.userpicImageView.layer.borderWidth = 0.0;
        }
    }
    
    
    
    self.nameLabel.font = [UIFont museoFontOfSize:17.0];
    
    
//    if(!user.isViewed){
//        self.nameLabel.font = [UIFont boldMuseoFontOfSize:17.0];
//    }else{
//        self.nameLabel.font = [UIFont museoFontOfSize:17.0];
//    }

}



@end
