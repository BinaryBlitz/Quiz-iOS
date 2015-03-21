//
//  UIViewController+QZBControllerCategory.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 19/03/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "UIViewController+QZBControllerCategory.h"


@implementation UIViewController (QZBControllerCategory)

-(void)initStatusbarWithColor:(UIColor *)color{
    [self setNeedsStatusBarAppearanceUpdate];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    UIBarButtonItem *backButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@""
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
    
    [self.navigationController.navigationBar
     setBackIndicatorImage:[UIImage imageNamed:@"backWhiteIcon"]];
    [self.navigationController.navigationBar
     setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"backWhiteIcon"]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    self.navigationController.navigationBar.barTintColor = color;
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
}


-(void)showAlertAboutAchievmentWithDict:(NSDictionary *)dict{
    
    // QZBAchievement *achievment = self.achivArray[indexPath.row];
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.backgroundType = Blur;
    alert.showAnimationType = FadeIn;
    
    NSString *descr =  @"Поздравляем!\n Вы получили новое достижение!";
    NSString *name = dict[@"name"];
    
    
    [alert showCustom:self
                image:[UIImage imageNamed:@"achiv"]
                color:[UIColor lightBlueColor]
                title:name
             subTitle:descr
     closeButtonTitle:@"ОК"
             duration:0.0f];
    
    
    
}


@end
