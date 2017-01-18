//
//  QZBRatingPageVC.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 06/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "QZBRatingTVC.h"
#import "QZBUserProtocol.h"

@interface QZBRatingPageVC
    : UIPageViewController <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

- (void)showLeftVC;
- (void)showRightVC;
- (void)showCenterVC;

- (void)setAllTimeRanksWithTop:(NSArray *)topArray playerArray:(NSArray *)playerArray;
- (void)setWeekRanksWithTop:(NSArray *)topArray playerArray:(NSArray *)playerArray;
- (void)setFriendsRanksWithTop:(NSArray *)topArray playerArray:(NSArray *)playerArray;

- (void)showUserPage:(id<QZBUserProtocol>)user;

@end
