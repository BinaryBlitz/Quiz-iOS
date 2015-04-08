//
//  QZBAchievementCollectionCell.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 11/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBAchievementCollectionCell.h"

@implementation QZBAchievementCollectionCell

-(void)awakeFromNib{
    self.achievementTitle.adjustsFontSizeToFitWidth = YES;
   // self.achievementTitle.minimumScaleFactor = 1.5;
}

@end
