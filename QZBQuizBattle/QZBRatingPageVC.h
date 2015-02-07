//
//  QZBRatingPageVC.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 06/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QZBRatingPageVC : UIPageViewController<UIPageViewControllerDelegate, UIPageViewControllerDataSource>

-(void)showLeftVC;
-(void)showRightVC;
@end
