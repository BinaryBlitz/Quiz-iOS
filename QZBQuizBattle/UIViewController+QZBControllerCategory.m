//
//  UIViewController+QZBControllerCategory.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 19/03/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "UIViewController+QZBControllerCategory.h"
#import "QZBServerManager.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@implementation UIViewController (QZBControllerCategory)

- (void)initStatusbarWithColor:(UIColor *)color {
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
    [self.navigationController.navigationBar setTitleTextAttributes:@{
        NSForegroundColorAttributeName : [UIColor whiteColor],
        NSFontAttributeName : font
    }];

    [[self navigationController] setNavigationBarHidden:NO animated:NO];
}

- (void)showAlertAboutAchievmentWithDict:(NSDictionary *)dict {
    // QZBAchievement *achievment = self.achivArray[indexPath.row];

    NSDictionary *d = dict[@"badge"];

    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.backgroundType = Blur;
    alert.showAnimationType = FadeIn;

    NSString *descr = @"Поздравляем!\n Вы получили новое " @"достиже" @"н" @"и" @"е" @"!";
    NSString *name = d[@"name"];

    [alert alertIsDismissed:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
                           [self setNeedsStatusBarAppearanceUpdate];
                       });
    }];

    UIImageView *v = [[UIImageView alloc] init];
    NSString *urlAppend = d[@"icon_url"];

    if (![urlAppend isEqual:[NSNull null]] && urlAppend) {
        NSString *urlAsString = [QZBServerBaseUrl stringByAppendingString:urlAppend];

        NSURL *imgURl = [NSURL URLWithString:urlAsString];

        NSURLRequest *imageRequest =
            [NSURLRequest requestWithURL:imgURl
                             cachePolicy:NSURLRequestReturnCacheDataElseLoad
                         timeoutInterval:60];

        [v setImageWithURLRequest:imageRequest
                  placeholderImage:[UIImage imageNamed:@"achiv"]
                           success:nil
                           failure:nil];
    }else{
        v.image = [UIImage imageNamed:@"achiv"];
    }

    [alert showCustom:self.navigationController
                   image:v.image
                   color:[UIColor lightBlueColor]
                   title:name
                subTitle:descr
        closeButtonTitle:@"ОК"
                duration:0.0f];
}


- (void)showAlertAboutUnabletoPlay {
    // QZBAchievement *achievment = self.achivArray[indexPath.row];
    
  //  NSDictionary *d = dict[@"badge"];
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.backgroundType = Blur;
    alert.showAnimationType = FadeIn;
    
    NSString *descr = @"Вы не можете играть сами с собой!";
    
    [alert alertIsDismissed:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
                           [self setNeedsStatusBarAppearanceUpdate];
                       });
    }];
    // UIImageView *v = [[UIImageView alloc] init];

    
    [alert showInfo:self.navigationController
              title:@"Ошибка"
           subTitle:descr
   closeButtonTitle:@"ОК"
           duration:0.0];
    
}


-(void)showAlertAboutUnvisibleTopic:(NSString *)topicName{
    // NSDictionary *d = dict[@"badge"];
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.backgroundType = Blur;
    alert.showAnimationType = FadeIn;
    
    // NSString *descr = @"Поздравляем!\n Вы получили новое " @"достиже" @"н" @"и" @"е" @"!";
    //NSString *name = d[@"name"];
    
    [alert alertIsDismissed:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
                           [self setNeedsStatusBarAppearanceUpdate];
                       });
    }];
    
    NSString *title = [NSString stringWithFormat:@"Топик не куплен!"];
    NSString *subTitle = [NSString
                          stringWithFormat:@"Перейти в магазин, чтобы купить топик '%@'?",
                          topicName];
    
    alert.completeButtonFormatBlock = ^NSDictionary*(void){
        NSDictionary *formatDict = @{@"backgroundColor":[UIColor middleDarkGreyColor]};
        return formatDict;
    };
    
    [alert addButton:@"Да" actionBlock:^{
        self.tabBarController.selectedIndex = 4;
    }];
    
    
    [alert showInfo:self.navigationController
              title:title subTitle:subTitle
   closeButtonTitle:@"Нет" duration:0.0f];
    
    
}


- (UILabel *)labelForNum:(NSInteger)num inView:(UIView *)view {
    UILabel *centralLabel =
        [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(view.frame) / 2.0,
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
