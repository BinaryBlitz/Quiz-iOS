//
//  QZBRatingMainVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 07/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRatingMainVC.h"
#import "QZBRatingPageVC.h"

@interface QZBRatingMainVC ()

@end

@implementation QZBRatingMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.multipleTouchEnabled = NO;
    
   // self.rightButton.
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)leftButtonAction:(UIBarButtonItem *)sender {
    NSLog(@"%@", self.childViewControllers.debugDescription);
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    });

    if ([[self.childViewControllers firstObject] isKindOfClass:[QZBRatingPageVC class]]) {
        QZBRatingPageVC *pageVC = (QZBRatingPageVC *)[self.childViewControllers firstObject];
        [pageVC showLeftVC];
    }
}

- (IBAction)rightButtonAction:(UIBarButtonItem *)sender {
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    });
    
    
    if ([[self.childViewControllers firstObject] isKindOfClass:[QZBRatingPageVC class]]) {
        QZBRatingPageVC *pageVC = (QZBRatingPageVC *)[self.childViewControllers firstObject];
        [pageVC showRightVC];
    }
}

@end
