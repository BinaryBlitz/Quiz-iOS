//
//  QZBRatingCategoryChooserVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 10/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRatingCategoryChooserVC.h"
#import "QZBRatingMainVC.h"
#import "QZBChooseThisCategoryCell.h"
#import "UIViewController+QZBControllerCategory.h"

@interface QZBRatingCategoryChooserVC ()

@end

@implementation QZBRatingCategoryChooserVC

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *backButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@""
                                         style:UIBarButtonItemStylePlain
                                        target:nil
                                        action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];

    [self initStatusbarWithColor:[UIColor blackColor]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [super tableView:tableView numberOfRowsInSection:section] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        QZBChooseThisCategoryCell *cell =
            [tableView dequeueReusableCellWithIdentifier:@"allCategory"];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        NSIndexPath *ip =
            [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
        return [super tableView:tableView cellForRowAtIndexPath:ip];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if ([[self.navigationController.viewControllers firstObject]
                isKindOfClass:[QZBRatingMainVC class]]) {
            QZBRatingMainVC *mainVC =
                (QZBRatingMainVC *)[self.navigationController.viewControllers firstObject];
            mainVC.category = nil;
            mainVC.topic = nil;
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    } else {
        NSIndexPath *ip = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.row];
        [super tableView:tableView didSelectRowAtIndexPath:ip];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 60.0;
    } else {
        NSIndexPath *newIp =
            [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
        return [super tableView:tableView heightForRowAtIndexPath:newIp];
    }
}

@end
