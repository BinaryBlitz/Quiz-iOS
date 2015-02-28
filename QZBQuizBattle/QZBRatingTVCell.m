//
//  QZBRatingTVCell.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 06/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRatingTVCell.h"
#import "QZBUserInRating.h"
#import "QZBUser.h"
#import "QZBCurrentUser.h"

@interface QZBRatingTVCell()

@property (strong, nonatomic) QZBUserInRating *user;


@end
@implementation QZBRatingTVCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setCellWithUser:(QZBUserInRating *)user{
    
    self.user = user;
    
    if (user.userID == [QZBCurrentUser sharedInstance].user.userID ) {
        NSMutableAttributedString *atrName =
        [[NSMutableAttributedString alloc] initWithString:user.name];
        UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:18.0];
        [atrName addAttribute:NSFontAttributeName
                        value:font
                        range:NSMakeRange(0, [atrName length])];
        self.name.attributedText = atrName;
        
    } else {
        self.name.text = user.name;
    }
    
    self.numberInRating.text = [NSString stringWithFormat:@"%ld", user.position];
    
    self.score.text = [NSString stringWithFormat:@"%ld", user.points];
    
  //  NSURL *url = [NSURL URLWithString:self.urlString];
    
   // [self.userpic setImageWithURL:url];
    
}

@end
