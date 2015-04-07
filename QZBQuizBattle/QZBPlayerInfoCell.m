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

@interface QZBPlayerInfoCell ()

@property(strong, nonatomic) JSBadgeView *badgeView;

@end

@implementation QZBPlayerInfoCell

- (void)awakeFromNib {
    // Initialization code
    
    NSLog(@"awake from nib");
    self.badgeView = [[JSBadgeView alloc] initWithParentView:self.friendsButton
                                                   alignment:JSBadgeViewAlignmentTopRight];
    
    //[self addDropShadows];
    
    
    
}

-(void)setBAdgeCount:(NSInteger)count{
    
    NSLog(@"badge count %ld", (long)count);
    if(count <= 0){
        self.badgeView.badgeText = @"";
        self.badgeView.hidden = YES;
    } else{

        self.badgeView.badgeText =  [NSString stringWithFormat:@"%ld", (long)count];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
    
}



@end
