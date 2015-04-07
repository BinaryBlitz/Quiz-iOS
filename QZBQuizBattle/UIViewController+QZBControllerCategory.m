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
    
    self.navigationController.navigationBar.translucent = NO;
    
    UIFont *font = [UIFont boldSystemFontOfSize:20];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],NSFontAttributeName:font}];
    
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
}


-(void)showAlertAboutAchievmentWithDict:(NSDictionary *)dict{
    
    // QZBAchievement *achievment = self.achivArray[indexPath.row];
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.backgroundType = Blur;
    alert.showAnimationType = FadeIn;
    
    NSString *descr =  @"Поздравляем!\n Вы получили новое достижение!";
    
    
    NSDictionary *achievDict = dict[@"badge"];
    
    NSString *name = achievDict[@"name"];
    
    
    [alert showCustom:self
                image:[UIImage imageNamed:@"achiv"]
                color:[UIColor lightBlueColor]
                title:name
             subTitle:descr
     closeButtonTitle:@"ОК"
             duration:0.0f];
    
}

-(void)calculateLevel:(NSInteger *)level levelProgress:(float *)levelProgress fromScore:(NSInteger)score{


    *level = score/100;
    *levelProgress = (score%100)/100.0;
    
}

-(UILabel *)labelForNum:(NSInteger) num inView:(UIView *)view{
    
    UILabel *centralLabel = [[UILabel alloc]
                             initWithFrame:CGRectMake(0, 0, CGRectGetWidth(view.frame) / 2.0,
                                                      CGRectGetWidth(view.frame) / 2.0)];

    centralLabel.text = [NSString stringWithFormat:@"%ld", num];
    centralLabel.textAlignment = NSTextAlignmentCenter;
    
    return centralLabel;
}

- (UITableViewCell *)parentCellForView:(id)theView {
    id viewSuperView = [theView superview];
    while (viewSuperView != nil) {
        if ([viewSuperView isKindOfClass:[UITableViewCell class]]) {
            return (UITableViewCell *)viewSuperView;
        } else {
            viewSuperView = [viewSuperView superview];
        }
    }
    return nil;
}


@end
