//
//  QZBRatingTVCell.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 06/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QZBRatingTVCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *numberInRating;
@property (weak, nonatomic) IBOutlet UIImageView *userpic;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *score;

@end
