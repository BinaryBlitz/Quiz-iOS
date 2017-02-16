//
//  QZBEndGameResultScoreCell.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 09/04/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QZBEndGameResultScoreCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

-(void)setResultScore:(NSInteger)score;

@end
