//
//  QZBRatingPageVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 06/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRatingPageVC.h"
//#import "QZBRatingTVC.h"
#import "QZBRatingMainVC.h"
#import "QZBServerManager.h"

@interface QZBRatingPageVC ()

@property (strong, nonatomic) NSArray *ratingTableViewControllers;
@property (assign, nonatomic) BOOL motionInProgress;
@property (assign, nonatomic) QZBRatingTableType currentTableType;

@end

@implementation QZBRatingPageVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.multipleTouchEnabled = NO;
    self.currentTableType = QZBRatingTableAllTime;
    self.expectedType = QZBRatingTableAllTime;

    self.delegate = self;
    self.dataSource = self;

    QZBRatingTVC *left = [self.storyboard instantiateViewControllerWithIdentifier:@"QZBRatingTVC"];
    left.urlString = @"https://pp.vk.me/c623927/v623927224/18741/HERAwb-7YGw.jpg";
    left.tableType = QZBRatingTableAllTime;
    QZBRatingTVC *right = [self.storyboard instantiateViewControllerWithIdentifier:@"QZBRatingTVC"];
    right.urlString = @"https://pp.vk.me/c622226/v622226864/19979/zuespQW29A4.jpg";
    right.tableType = QZBRatingTableWeek;

    NSLog(@"left %@ right %@", left, right);
    self.ratingTableViewControllers = @[ left, right ];

    self.currentTableType = QZBRatingTableAllTime;
    [self setViewControllers:@[ left ]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:nil];

    NSLog(@"loaded!");
    self.motionInProgress = NO;

    UIPanGestureRecognizer *panGestureRecognizer =
        [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRcognizer:)];

    [self.view addGestureRecognizer:panGestureRecognizer];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)panRcognizer:(id)sender {
    NSLog(@"mooved");
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
    willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    //  NSLog(@"transition start");
    self.motionInProgress = YES;
}

- (void)pageViewController:(UIPageViewController *)pageViewController
         didFinishAnimating:(BOOL)finished
    previousViewControllers:(NSArray *)previousViewControllers
        transitionCompleted:(BOOL)completed {
    self.motionInProgress = NO;

    if (!completed) {
        return;
    }

    // NSLog(@"current %@", [self.viewControllers firstObject]);

    // NSLog(@"finished %d comleted %d %@ current %@", finished, completed, [previousViewControllers debugDescription],
    //       [self.viewControllers lastObject]);

    if (finished && completed) {
        if (![[self.viewControllers lastObject] isEqual:[self.ratingTableViewControllers firstObject]]) {
            if ([self.parentViewController isKindOfClass:[QZBRatingMainVC class]]) {
                [self colorRightButton];
                self.currentTableType = QZBRatingTableWeek;
                //  NSLog(@"colored right");
            }

        } else if ([[self.viewControllers lastObject] isEqual:[self.ratingTableViewControllers firstObject]]) {
            if ([self.parentViewController isKindOfClass:[QZBRatingMainVC class]]) {
                [self colorLeftButton];
                self.currentTableType = QZBRatingTableAllTime;
            }
        }
    }
}

- (void)showLeftVC {
    NSLog(@"left button pressed");

    if (!self.motionInProgress) {
        QZBRatingTVC *leftPage = [self.ratingTableViewControllers firstObject];

        [self colorLeftButton];
        [self setViewControllers:@[ leftPage ]
                       direction:UIPageViewControllerNavigationDirectionReverse
                        animated:YES
                      completion:nil];
        self.currentTableType = QZBRatingTableAllTime;

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"expected %ld current %ld", self.expectedType, self.currentTableType);

            if (self.expectedType != self.currentTableType) {
                self.currentTableType = QZBRatingTableWeek;
                self.expectedType = QZBRatingTableWeek;
                [self colorRightButton];
                QZBRatingTVC *rightPage = [self.ratingTableViewControllers lastObject];
                [self setViewControllers:@[ rightPage ]
                               direction:UIPageViewControllerNavigationDirectionReverse
                                animated:NO
                              completion:^(BOOL finished) {
                                  NSLog(@"finished %d left canceled", finished);
                              }];
            }
        });
    }
}

- (void)showRightVC {
    NSLog(@"right button pressed");

    if (!self.motionInProgress) {
        QZBRatingTVC *rightPage = [self.ratingTableViewControllers lastObject];
        // QZBRatingTVC *leftPage = [self.ratingTableViewControllers firstObject];

        [self colorRightButton];

        //  __weak typeof(self) weakSelf = self;

        [self setViewControllers:@[ rightPage ]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:YES
                      completion:^(BOOL finished) {
                          NSLog(@"finished %d right", finished);

                      }];
        self.currentTableType = QZBRatingTableWeek;

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"expected %ld current %ld", self.expectedType, self.currentTableType);
            if (self.expectedType != self.currentTableType) {
                QZBRatingTVC *leftPage = [self.ratingTableViewControllers firstObject];
                self.currentTableType = QZBRatingTableAllTime;
                self.currentTableType = QZBRatingTableAllTime;
                [self colorLeftButton];
                [self setViewControllers:@[ leftPage ]
                               direction:UIPageViewControllerNavigationDirectionReverse
                                animated:NO
                              completion:^(BOOL finished) {
                                  NSLog(@"finished %d right canceled", finished);
                              }];
            }
        });
    }
}

- (void)colorRightButton {
    QZBRatingMainVC *parentVC = (QZBRatingMainVC *)self.parentViewController;

    parentVC.rightButton.tintColor = self.view.tintColor;
    parentVC.leftButton.tintColor = [UIColor lightGrayColor];
}

- (void)colorLeftButton {
    QZBRatingMainVC *parentVC = (QZBRatingMainVC *)self.parentViewController;

    parentVC.leftButton.tintColor = self.view.tintColor;
    parentVC.rightButton.tintColor = [UIColor lightGrayColor];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"began");
}

-(void)setAllTimeRanksWithTop:(NSArray *)topArray playerArray:(NSArray *)playerArray{
    
    QZBRatingTVC *leftPage = [self.ratingTableViewControllers firstObject];
    
    [leftPage setPlayersRanksWithTop:topArray playerArray:playerArray];
    
    
}

-(void)setWeekRanksWithTop:(NSArray *)topArray playerArray:(NSArray *)playerArray{
    QZBRatingTVC *rightPage = [self.ratingTableViewControllers lastObject];
    
    [rightPage setPlayersRanksWithTop:topArray playerArray:playerArray];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
