//
//  QZBMainGameScreenTVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 18/03/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBMainGameScreenTVC.h"
#import "QZBServerManager.h"
#import "QZBMainChallengesCell.h"
#import "UIViewController+QZBControllerCategory.h"
#import "UIColor+QZBProjectColors.h"
#import "QZBTopicTableViewCell.h"
#import "QZBDescriptionCell.h"  //mainDescriptionCell
#import <SVProgressHUD.h>
#import "QZBChallengeCell.h"
#import "QZBChallengeDescription.h"
#import "QZBGameTopic.h"

@interface QZBMainGameScreenTVC ()

@property (strong, nonatomic) NSArray *faveTopics;
@property (strong, nonatomic) NSArray *friendsTopics;
@property (strong, nonatomic) NSArray *featured;
@property (strong, nonatomic) NSArray *challenges;
@property (strong, nonatomic) NSMutableArray *workArray;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation QZBMainGameScreenTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    self.mainTableView.backgroundColor = [UIColor lightGreenColor];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(reloadTopicsData)
                  forControlEvents:UIControlEventValueChanged];
    
    [self.mainTableView addSubview:self.refreshControl];

    
}

-(NSMutableArray *)workArray{
    if(!_workArray){
        _workArray = [NSMutableArray array];
    }
    return _workArray;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //self.workArray = [NSMutableArray array];
   
    self.title = @"iQuiz";  // REDO

    [self initStatusbarWithColor:[UIColor blackColor]];
    
    [self reloadTopicsData];
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    [super prepareForSegue:segue sender:sender];
    
    
}

#pragma mark - UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return self.workArray.count;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
//    NSInteger result = 0;
//    
//    for(NSArray *arr in self.workArray){
//        if(arr.count>3){
//            result+=5;
//        }else{
//             result+=arr.count+1;
//        }
//    }
//  
//    return result;
    
    
    NSArray *arr = self.workArray[section];
    
    if(arr.count>3){
        return 5;
    }else{
        return arr.count;
    }
    
}




- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    QZBTopicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"topicCell"];
    
    NSArray *arr = self.workArray[indexPath.section];
    
    QZBGameTopic *topic = arr[indexPath.row];
    
    cell.backgroundColor = [self colorForSection:indexPath.section];
    
    NSInteger level = 0;
    float progress = 0.0;
    
    [self calculateLevel:&level levelProgress:&progress fromScore:[topic.points integerValue]];
    
    [cell initCircularProgressWithLevel:level progress:progress];
    
    cell.topicName.text = topic.name;
   
    return cell;
    
    
}


-(UIColor *)colorForSection:(NSInteger)section{
    
    if(section == 0){
        return [UIColor lightGreenColor];
    }else if(section==1){
        return [UIColor lightBlueColor];
    }else if(section == 2){
        return [UIColor lightRedColor];
    }else{
        return [UIColor brightRedColor];
    }
    
}



#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.reuseIdentifier isEqualToString:@"mainChallengeCell"]) {
        [self performSegueWithIdentifier:@"showChallenges" sender:nil];
    } else if ([cell.reuseIdentifier isEqualToString:@"mainDescriptionCell"]) {
        return;

    } else {
        // NSIndexPath *newIP = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0];

        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#(NSString *)#>
    

        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    
    //CGRect rect = CGRectMake(0, 0,CGRectGetWidth(tableView.frame), 48);
    
    UIView *view = [[UIView alloc] init];
    
    
    view.backgroundColor = [self colorForSection:section];
    
    CGRect rect = CGRectMake(0, 0,CGRectGetWidth(tableView.frame), 48);
    
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:20];
    
    [view addSubview:label];
    
    
    NSString *text = @"";
    NSArray *arr = self.workArray[section];
    
    if([arr isEqualToArray:self.faveTopics]){
        text = @"Любимые топики";
    }else if([arr isEqualToArray:self.friendsTopics]){
        text = @"Популярное у друзей";
        
    } else if([arr isEqualToArray:self.featured]){
        
        text = @"Популярные темы";
        
    }
    
    
    label.text = text;
    
    return view;
    
    
}
#pragma mark - actions

- (IBAction)playGameAction:(id)sender {
    
    UITableViewCell *cell = [self parentCellForView:sender];
    
    if(cell){
    
        NSIndexPath *ip = [self.mainTableView indexPathForCell: cell];
        
        NSArray *arr = self.workArray[ip.section];
    
        self.choosedTopic = arr[ip.row];
        
        [self performSegueWithIdentifier:@"showPreparingVC" sender:nil];
        
        
    }
    
}

- (IBAction)throwChallengeAction:(id)sender {
    
    UITableViewCell *cell = [self parentCellForView:sender];
    
    if(cell){
        
        NSIndexPath *ip = [self.mainTableView indexPathForCell: cell];
        
        NSArray *arr = self.workArray[ip.section];
        
        self.choosedTopic = arr[ip.row];
        
        //[self performSegueWithIdentifier:@"showPreparingVC" sender:nil];
        
        //[self performSegueWithIdentifier:@"showRate" sender:nil];
        [self performSegueWithIdentifier:@"showFriendsChallenge" sender:nil];
    }
    
    
}
- (IBAction)showRateAction:(id)sender {
    
    UITableViewCell *cell = [self parentCellForView:sender];
    
    if(cell){
        
        NSIndexPath *ip = [self.mainTableView indexPathForCell: cell];
        
        NSArray *arr = self.workArray[ip.section];
        
        self.choosedTopic = arr[ip.row];
        
        //[self performSegueWithIdentifier:@"showPreparingVC" sender:nil];
       // [self performSegueWithIdentifier:@"showFriendsChallenge" sender:nil];
        
        [self performSegueWithIdentifier:@"showRate" sender:nil];
    }
    
    
}

-(void)reloadTopicsData{
    
    [[QZBServerManager sharedManager]
     GETTopicsForMainOnSuccess:^(NSArray *fave, NSArray *friendsFave, NSArray *featured) {
         
         [self.refreshControl endRefreshing];
         
         self.faveTopics = fave;
         self.friendsTopics = friendsFave;
         self.featured = featured;
         
         [self.workArray removeAllObjects];
         
         if(featured.count>0){
             [self.workArray addObject:featured];
         }
         
         if(fave.count>0){
             [self.workArray addObject:fave];
         }
         
         if(friendsFave.count>0){
             [self.workArray addObject:friendsFave];
         }
         
         NSLog(@"in arr fave %@",fave);
         
         [self.mainTableView reloadData];
         
     }
     onFailure:^(NSError *error, NSInteger statusCode){
         [self.refreshControl endRefreshing];
         
         
     }];
    
}



//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    CGFloat sectionHeaderHeight = 48;
//    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
//        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
//    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
//        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
//    }
//}

//- (void)tableView:(UITableView *)tableView
//      willDisplayCell:(UITableViewCell *)cell
//    forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.row == 2) {
//        tableView.backgroundColor = [UIColor lightGreenColor];
//    }
//    if (indexPath.row == [tableView numberOfRowsInSection:0]) {
//        tableView.backgroundColor = [UIColor lightGreenColor];
//    }
//}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
