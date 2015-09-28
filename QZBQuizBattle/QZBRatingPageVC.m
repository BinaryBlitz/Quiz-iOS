//
//  QZBRatingPageVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 06/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRatingPageVC.h"
#import "QZBRatingMainVC.h"
#import "QZBServerManager.h"

#import <DDLog.h>
static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface QZBRatingPageVC ()<UIScrollViewDelegate>
@property (strong, nonatomic) NSArray *ratingTableViewControllers;
@end

@implementation QZBRatingPageVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.multipleTouchEnabled = NO;
    self.delegate = self;
    self.dataSource = self;
    
    for(UIView *v in self.view.subviews){
        if([v isKindOfClass:[UIScrollView class]]){
            UIScrollView *scrollView = (UIScrollView *)v;
            scrollView.delegate = self;
        }
    }

    QZBRatingTVC *left = [self.storyboard instantiateViewControllerWithIdentifier:@"QZBRatingTVC"];
    left.tableType = QZBRatingTableAllTime;
    QZBRatingTVC *center = [self.storyboard instantiateViewControllerWithIdentifier:@"QZBRatingTVC"];
    center.tableType = QZBRatingTableWeek;
    QZBRatingTVC *right = [self.storyboard instantiateViewControllerWithIdentifier:@"QZBRatingTVC"];
    right.tableType = QZBRatingTableFriends;
    
    self.ratingTableViewControllers = @[ left, center,right ];

    [self setViewControllers:@[ left ]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:nil];

}


#pragma mark -

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index {
    if (([self.ratingTableViewControllers count] == 0) || (index >= [self.ratingTableViewControllers count])) {
        return nil;
    }

    return self.ratingTableViewControllers[index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = [self.ratingTableViewControllers indexOfObject:viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }

    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = [self.ratingTableViewControllers indexOfObject:viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.ratingTableViewControllers count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return self.ratingTableViewControllers.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

- (void)pageViewController:(UIPageViewController *)pageViewController
         didFinishAnimating:(BOOL)finished
    previousViewControllers:(NSArray *)previousViewControllers
        transitionCompleted:(BOOL)completed {
 //   self.motionInProgress = NO;

    if (!completed) {
        return;
    }

    if (finished && completed) {
        QZBRatingTVC *rtvc = [self.viewControllers lastObject];
        QZBRatingMainVC *mainVC = (QZBRatingMainVC *)self.parentViewController;
        switch (rtvc.tableType) {
            case QZBRatingTableAllTime:
                mainVC.typeChooserSegmentControl.selectedSegmentIndex = 0;
                break;
            case QZBRatingTableWeek:
                mainVC.typeChooserSegmentControl.selectedSegmentIndex = 1;
                break;
            case QZBRatingTableFriends:
                mainVC.typeChooserSegmentControl.selectedSegmentIndex = 2;
                break;
            default:
                break;
        }
    }
}

- (void)showLeftVC {
//    DDLogVerbose(@"left button pressed");
//
   // if (!self.motionInProgress) {
        QZBRatingTVC *leftPage = [self.ratingTableViewControllers firstObject];

       // [self colorLeftButton];
        [self setViewControllers:@[ leftPage ]
                       direction:UIPageViewControllerNavigationDirectionReverse
                        animated:YES
                      completion:nil];
    //    self.currentTableType = QZBRatingTableAllTime;
  //  }
}

-(void)showCenterVC {
    QZBRatingTVC *centerPage = self.ratingTableViewControllers[1];
    UIPageViewControllerNavigationDirection navDir = UIPageViewControllerNavigationDirectionForward;
    QZBRatingTVC *currentPage = (QZBRatingTVC *)[self.viewControllers lastObject];
    if(currentPage.tableType == QZBRatingTableFriends) {
        navDir = UIPageViewControllerNavigationDirectionReverse;
    }
    
    [self setViewControllers:@[ centerPage, ]
                   direction:navDir
                    animated:YES
                  completion:nil];
}

- (void)showRightVC {

    QZBRatingTVC *rightPage = [self.ratingTableViewControllers lastObject];
  
        [self setViewControllers:@[ rightPage ]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:YES
                      completion:^(BOOL finished) {
                       
                    }];

}

- (void)colorRightButton {
//    QZBRatingMainVC *parentVC = (QZBRatingMainVC *)self.parentViewController;
//
//    [parentVC.leftButton setTitleColor:[UIColor lightGrayColor]
//                              forState:UIControlStateNormal];
//    [parentVC.rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    //parentVC.leftButton.titleLabel.textColor = [UIColor lightGrayColor];
//
//    
//    parentVC.leftSliderConstraint.constant = parentVC.rightButton.frame.size.width+8;
//    parentVC.rightSliderConstraint.constant = -parentVC.rightButton.frame.size.width - 8;
//
//    
//    [UIView animateWithDuration:0.2 animations:^{
//        [parentVC.sliderView layoutIfNeeded];
//       // parentVC.sliderView.frame = parentVC.rightButton.frame;
//      //  [parentVC.sliderView layoutIfNeeded];
//    } completion:^(BOOL finished) {
//         //[parentVC.sliderView layoutIfNeeded];
//    }];
}

- (void)colorLeftButton {
//    QZBRatingMainVC *parentVC = (QZBRatingMainVC *)self.parentViewController;
//  
//   // parentVC.leftButton.titleLabel.textColor = [UIColor blackColor];
//    [parentVC.leftButton setTitleColor:[UIColor blackColor]
//                              forState:UIControlStateNormal];
//    [parentVC.rightButton setTitleColor:[UIColor lightGrayColor]
//                               forState:UIControlStateNormal];
//
//    parentVC.leftSliderConstraint.constant = 1;
//    parentVC.rightSliderConstraint.constant = 0;
//    
//    [UIView animateWithDuration:0.2 animations:^{
//        [parentVC.sliderView layoutIfNeeded];
//  
//        } completion:^(BOOL finished) {
//        }];
}

-(void)colorCentralButton {
    
}


-(void)setAllTimeRanksWithTop:(NSArray *)topArray playerArray:(NSArray *)playerArray{
    QZBRatingTVC *leftPage = [self.ratingTableViewControllers firstObject];
    [leftPage setPlayersRanksWithTop:topArray playerArray:playerArray];
}

-(void)setWeekRanksWithTop:(NSArray *)topArray playerArray:(NSArray *)playerArray{
    QZBRatingTVC *centralPage = self.ratingTableViewControllers[1];
    [centralPage setPlayersRanksWithTop:topArray playerArray:playerArray];
}

-(void)setFriendsRanksWithTop:(NSArray *)topArray playerArray:(NSArray *)playerArray{
    QZBRatingTVC *rightPage = [self.ratingTableViewControllers lastObject];
    [rightPage setPlayersRanksWithTop:topArray playerArray:playerArray];
}



-(void)showUserPage:(id<QZBUserProtocol>)user{
    if([self.parentViewController isKindOfClass:[QZBRatingMainVC class]]){
        QZBRatingMainVC *vc = (QZBRatingMainVC *)self.parentViewController;
        [vc showUserPage:user];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        });
}



@end
