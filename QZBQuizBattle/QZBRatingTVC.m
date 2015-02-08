//
//  QZBRatingVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 06/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRatingTVC.h"
#import "QZBRatingTVCell.h"
#import "UIImageView+AFNetworking.h"

@interface QZBRatingTVC () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation QZBRatingTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.multipleTouchEnabled = NO;

    self.ratingTableView.delegate   = self;
    self.ratingTableView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QZBRatingTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ratingCell"];
    cell.numberInRating.text = [NSString stringWithFormat:@"%ld", (indexPath.row + 1)];

    NSURL *url = [NSURL URLWithString:self.urlString];

    [cell.userpic setImageWithURL:url];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before
navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
