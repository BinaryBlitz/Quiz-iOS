//
//  UIViewController+QZBControllerCategory.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 19/03/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SCLAlertView-Objective-C/SCLAlertView.h> 
#import "UIColor+QZBProjectColors.h"

@interface UIViewController (QZBControllerCategory)

-(void)initStatusbarWithColor:(UIColor *)color;
-(void)showAlertAboutAchievmentWithDict:(NSDictionary *)dict;
//-(void)calculateLevel:(NSInteger *)level
//        levelProgress:(float *)levelProgress
//            fromScore:(NSInteger)score;
-(UILabel *)labelForNum:(NSInteger) num
                 inView:(UIView *)view;

- (UITableViewCell *)parentCellForView:(id)theView;

@end
