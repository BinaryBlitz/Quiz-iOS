//
//  QZBRatingPageVC.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 06/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "QZBRatingTVC.h"

@interface QZBRatingPageVC : UIPageViewController <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property(assign, nonatomic) QZBRatingTableType expectedType;

- (void)showLeftVC;
- (void)showRightVC;

-(void)setAllTimeRanksWithTop:(NSArray *)topArray playerArray:(NSArray *)playerArray;
-(void)setWeekRanksWithTop:(NSArray *)topArray playerArray:(NSArray *)playerArray;


@end
