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
#import "QZBRatingPageVC.h"
#import "QZBUserInRating.h"
#import "QZBCurrentUser.h"
#import "QZBUser.h"

@interface QZBRatingTVC () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *topRank;     // QZBUserInRating
@property (strong, nonatomic) NSArray *playerRank;  // QZBUserInRating

@end

@implementation QZBRatingTVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.multipleTouchEnabled = NO;

    self.ratingTableView.delegate = self;
    self.ratingTableView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.ratingTableView reloadData];
    NSLog(@"it shown %ld", self.tableType);
    if ([self.parentViewController isKindOfClass:[QZBRatingPageVC class]]) {
        QZBRatingPageVC *pageVC = (QZBRatingPageVC *)self.parentViewController;
        pageVC.expectedType = self.tableType;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"hided %ld", self.tableType);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger result = 0;

    if (self.topRank) {
        result += [self.topRank count];
    }

    if (self.playerRank) {
        result += [self.playerRank count];
    }
    if([self shouldShowSeperator]){
        result++;
    }

    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *resultCell = nil;

    if (indexPath.row == [self.topRank count] && [self shouldShowSeperator]) {
        resultCell = [tableView dequeueReusableCellWithIdentifier:@"ratingSeperator"];
    } else {
        QZBRatingTVCell *cell =
            (QZBRatingTVCell *)[tableView dequeueReusableCellWithIdentifier:@"ratingCell"];
        QZBUserInRating *user = nil;

        if (indexPath.row < [self.topRank count]) {
            user = self.topRank[indexPath.row];
        } else {
            if([self shouldShowSeperator]){
                user = self.playerRank[indexPath.row - [self.topRank count]-1];
            }else{
                user = self.playerRank[indexPath.row - [self.topRank count]];
            }
        }

        [self setCell:cell user:user];
        resultCell = cell;
    }
    return resultCell;
}


-(void)setCell:(QZBRatingTVCell *)cell user:(QZBUserInRating *)user{
    
    [cell setCellWithUser:user];
    
   // NSURL *url = [NSURL URLWithString:self.urlString];
    if(user.imageURL){
    [cell.userpic setImageWithURL:user.imageURL];
    }else{
        [cell.userpic setImage:[UIImage imageNamed:@"icon_register"]];//redo
    }
    
    
}
//-(void)setUserCell:(QZBRatingTVCell *)cell

-(BOOL)shouldShowSeperator{
    
    if(self.playerRank){
        QZBUserInRating *user = [self.playerRank firstObject];
        if(user.position <= 21){
            return NO;
        }
    }
    if(!self.topRank || !self.playerRank){
        return NO;
    }
    return YES;
    
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if(![cell isKindOfClass:[QZBRatingTVCell class]]){
        return;
    }
    
    if([self.parentViewController isKindOfClass:[QZBRatingPageVC class]]){
        
        QZBRatingTVCell *userCell = (QZBRatingTVCell *)cell;
        QZBUserInRating *user = userCell.user;
        
        QZBRatingPageVC *vc = (QZBRatingPageVC *)self.parentViewController;
        
        [vc showUserPage:user];
        
    }
    
    
}

- (void)setPlayersRanksWithTop:(NSArray *)topArray playerArray:(NSArray *)playerArray {
    self.topRank = topArray;
    self.playerRank = playerArray;

    [self.ratingTableView reloadData];
    NSLog(@"%@ \n %@", self.topRank, self.playerRank);
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
