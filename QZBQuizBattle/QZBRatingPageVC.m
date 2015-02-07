//
//  QZBRatingPageVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 06/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRatingPageVC.h"
#import "QZBRatingTVC.h"
#import "QZBRatingMainVC.h"

@interface QZBRatingPageVC ()

@property (strong, nonatomic) NSArray *ratingTableViewControllers;

@end

@implementation QZBRatingPageVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.delegate = self;
    self.dataSource = self;

    QZBRatingTVC *left = [self.storyboard instantiateViewControllerWithIdentifier:@"QZBRatingTVC"];
    QZBRatingTVC *right = [self.storyboard instantiateViewControllerWithIdentifier:@"QZBRatingTVC"];

    self.ratingTableViewControllers = @[ left, right ];

    [self setViewControllers:@[ left ]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:nil];

    NSLog(@"loaded!");

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    NSLog(@"called");

    if (finished && completed &&
        [[previousViewControllers firstObject] isEqual:[self.ratingTableViewControllers firstObject]]) {
        if ([self.parentViewController isKindOfClass:[QZBRatingMainVC class]]) {
            [self colorRightButton];
        }

    } else if (finished && completed &&
               ![[previousViewControllers firstObject] isEqual:[self.ratingTableViewControllers firstObject]]) {
        if ([self.parentViewController isKindOfClass:[QZBRatingMainVC class]]) {
            [self colorLeftButton];
        }
    }
}

- (void)showLeftVC {
    NSLog(@"button pressed");

    QZBRatingTVC *leftPage = [self.ratingTableViewControllers firstObject];

    [self colorLeftButton];
    [self setViewControllers:@[ leftPage ]
                   direction:UIPageViewControllerNavigationDirectionReverse
                    animated:YES
                  completion:nil];
}

- (void)showRightVC {
    NSLog(@"button pressed");

    QZBRatingTVC *rightPage = [self.ratingTableViewControllers lastObject];

    [self colorRightButton];
    [self setViewControllers:@[ rightPage ]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:YES
                  completion:nil];
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
