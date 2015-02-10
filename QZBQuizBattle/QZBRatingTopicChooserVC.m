//
//  QZBRatingTopicChooserVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 10/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRatingTopicChooserVC.h"
#import "QZBRatingMainVC.h"
#import "QZBGameTopic.h"

@interface QZBRatingTopicChooserVC () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation QZBRatingTopicChooserVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [super tableView:tableView numberOfRowsInSection:section] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        cell.textLabel.text = @"Рейтин по выбранной категории";
        return cell;
    } else {
        NSIndexPath *ip = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
        return [super tableView:tableView cellForRowAtIndexPath:ip];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    QZBRatingMainVC *mainVC = nil;
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[QZBRatingMainVC class]]) {
            mainVC = (QZBRatingMainVC *)vc;
            break;
        }
    }

    if (indexPath.row == 0) {
        mainVC.topic = nil;
        mainVC.category = self.category;

    } else {
        mainVC.topic = self.topics[indexPath.row - 1];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
