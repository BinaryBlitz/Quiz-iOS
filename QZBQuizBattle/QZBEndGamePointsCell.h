//
//  QZBEndGamePointsCell.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 09/04/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UAProgressView.h>

@interface QZBEndGamePointsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointsNameLabel;
@property (weak, nonatomic) IBOutlet UAProgressView *circleView;


-(void)setCentralLabelWithNimber:(NSInteger)multiplier;
-(void)setScore:(NSUInteger)score;

@end
