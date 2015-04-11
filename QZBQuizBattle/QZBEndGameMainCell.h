//
//  QZBEndGameMainCell.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 09/04/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JSBadgeView;

@interface QZBEndGameMainCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UIImageView *opponentImage;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *opponentNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *firstUserScore;
@property (weak, nonatomic) IBOutlet UILabel *opponentScore;

@property (weak, nonatomic) IBOutlet UILabel *resultOfSessionLabel;
@property (strong, nonatomic) JSBadgeView *userBV;
@property (strong, nonatomic) JSBadgeView *opponentBV;

-(void)initCell;

@end
