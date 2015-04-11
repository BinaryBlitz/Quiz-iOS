//
//  QZBEndGameResultScoreCell.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 09/04/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBEndGameResultScoreCell.h"
#import "UITableViewCell+QZBCellCategory.h"
#import "NSString+QZBStringCategory.h"

@implementation QZBEndGameResultScoreCell

- (void)awakeFromNib {
    // Initialization code
    [self addDropShadows];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setResultScore:(NSInteger)score{
    
    NSString *scoreName = [NSString endOfWordFromNumber:score];
    self.resultLabel.text = [NSString stringWithFormat:@"+%ld %@",score, scoreName];
}

@end
