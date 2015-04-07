//
//  QZBMainBoosterCell.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 14/03/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QZBMainBoosterCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIButton *doubleBoosterButton;
@property (weak, nonatomic) IBOutlet UIButton *tripleBoosterButton;
@property (weak, nonatomic) IBOutlet UIButton *fiveTimesBoosterButton;
@property (weak, nonatomic) IBOutlet UILabel *doubleBoosterLabel;
@property (weak, nonatomic) IBOutlet UILabel *tripleBoosterLabel;
@property (weak, nonatomic) IBOutlet UILabel *fiveTimesBoosterLabel;

-(void)configButtonPurchased:(UIButton *)button;
-(void)configButtonNotPurchased:(UIButton *)button;


@end
