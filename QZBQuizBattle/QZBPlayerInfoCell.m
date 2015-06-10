//
//  QZBPlayerInfoCell.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 22/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBPlayerInfoCell.h"
#import <JSBadgeView/JSBadgeView.h>
#import "UITableViewCell+QZBCellCategory.h"
#import "UIButton+Badge.h"

@interface QZBPlayerInfoCell ()

@property(strong, nonatomic) JSBadgeView *badgeView;

@end

@implementation QZBPlayerInfoCell

- (void)awakeFromNib {

    self.playerUserpic.userInteractionEnabled = YES;
    
    self.multiUseButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.multiUseButton.titleLabel.minimumScaleFactor = 0.5;
    self.multiUseButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
    
    self.messageButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.messageButton.titleLabel.minimumScaleFactor = 0.5;
    self.messageButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
    
    self.messageButton.titleLabel.numberOfLines = 0;
    CGFloat inset = CGRectGetHeight(self.frame) / 5;
    self.messageButton.titleEdgeInsets = UIEdgeInsetsMake(inset / 3, inset / 3, inset / 3, inset / 3);
    
    
}

-(void)setBAdgeCount:(NSInteger)count{
    
//    NSLog(@"badge count %ld", (long)count);
    if(count <= 0){
        self.friendsButton.badgeValue = nil;
    } else{

        self.friendsButton.badgeOriginX = 3*self.friendsButton.bounds.size.width/4;
        self.friendsButton.badgeOriginY = self.friendsButton.bounds.size.height/5;
        self.friendsButton.badgeMinSize = 10;
        
        self.friendsButton.badgeValue = [NSString stringWithFormat:@"%ld", (long)count];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}



@end
