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

@interface QZBRatingTVC () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSArray *topRank;   //QZBUserInRating
@property (strong, nonatomic) NSArray *playerRank;//QZBUserInRating

@end

@implementation QZBRatingTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.multipleTouchEnabled = NO;

    self.ratingTableView.delegate   = self;
    self.ratingTableView.dataSource = self;
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.ratingTableView reloadData];
    NSLog(@"it shown %ld", self.tableType);
    if([self.parentViewController isKindOfClass:[QZBRatingPageVC class]]){
        
        QZBRatingPageVC *pageVC = (QZBRatingPageVC *)self.parentViewController;
        pageVC.expectedType = self.tableType;
       
        
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSLog(@"hided %ld", self.tableType);
}
/*
-(void)move:(UIPanGestureRecognizer *)sender{
    if(sender.state == UIGestureRecognizerStateBegan){
        NSLog(@"move");
    }else if (sender.state == UIGestureRecognizerStateCancelled ||sender.state == UIGestureRecognizerStateEnded){
        NSLog(@"ended");
    }
    
}*/




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    
    return [self.topRank count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QZBRatingTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ratingCell"];
    
    QZBUserInRating *user = self.topRank[indexPath.row];
    
    if(user.userID == [[QZBCurrentUser sharedInstance].user.user_id integerValue]){
       
        NSMutableAttributedString *atrName = [[NSMutableAttributedString alloc] initWithString:user.name];
        UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:18.0];
        [atrName addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [atrName length])];
        cell.name.attributedText = atrName;
        
    }else{
        cell.name.text = user.name;
    }
    
    cell.numberInRating.text = [NSString stringWithFormat:@"%ld", (indexPath.row + 1)];
   // cell.name.text = user.name;
    cell.score.text = [NSString stringWithFormat:@"%ld", user.points];

    NSURL *url = [NSURL URLWithString:self.urlString];

    [cell.userpic setImageWithURL:url];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



-(void)setPlayersRanksWithTop:(NSArray *)topArray playerArray:(NSArray *)playerArray{
    self.topRank = topArray;
    self.playerRank = playerArray;
    
    [self.ratingTableView reloadData];
    NSLog(@"%@ \n %@", self.topRank,self.playerRank);
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
