//
//  QZBEndGameVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 09/04/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBEndGameVC.h"
#import "QZBEndGameMainCell.h"
#import "QZBEndGamePointsCell.h"
#import "QZBEndGameResultScoreCell.h"
#import "QZBEndGameProgressCell.h"
#import "QZBSessionManager.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "UIViewController+QZBControllerCategory.h"
#import "QZBGameTopic.h"
#import <JSBadgeView.h>
#import "UIColor+QZBProjectColors.h"
#import "QZBCategory.h"

@interface QZBEndGameVC ()

@property(copy, nonatomic) NSString *firstUserName;
@property(copy, nonatomic) NSString *opponentUserName;
@property(assign, nonatomic) NSUInteger firstUserScore;
@property(assign, nonatomic) NSUInteger secondUserScore;
@property(copy, nonatomic) NSString *sessionResult;
@property(copy, nonatomic) NSURL *firstImageURL;
@property(copy, nonatomic) NSURL *opponentImageURL;
@property(strong, nonatomic) QZBGameTopic *topic;
@property(assign, nonatomic) NSInteger multiplier;
@property(assign, nonatomic) NSInteger beginScore;
@property(assign, nonatomic) NSInteger endScore;
@property(assign, nonatomic) BOOL progressShown;
@property(assign, nonatomic) BOOL cellInited;

@end

@implementation QZBEndGameVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.navigationItem.leftBarButtonItem = nil;
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    
   // self.progressShown = NO;
//    self.tabBarController.tabBar.hidden = NO;
//    
//    [self.tabBarController setHidesBottomBarWhenPushed:NO];
    
    
    // Do any additional setup after loading the view.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self initSessionResults];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
    
    [self.tabBarController setHidesBottomBarWhenPushed:NO];

    [self.tableView layoutIfNeeded];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(achievementGet:)
                                                 name:@"QZBAchievmentGet"
                                               object:nil];
    
    
    QZBGameTopic *topic = self.topic;
    
    QZBCategory *category = [[QZBServerManager sharedManager] tryFindRelatedCategoryToTopic:topic];
    if(category){
        
        NSURL *url = [NSURL URLWithString:category.background_url];
        NSURLRequest *imageRequest =
        [NSURLRequest requestWithURL:url
                         cachePolicy:NSURLRequestReturnCacheDataElseLoad
                     timeoutInterval:60];

        
        [self.backgroundImageView setImageWithURLRequest:imageRequest
                                        placeholderImage:nil
                                                 success:nil
                                                 failure:nil];
        
        
    }
   // [self.tableView layoutIfNeeded];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
////    [[NSNotificationCenter defaultCenter] removeObserver:self];
////    
////    [self.navigationController popToRootViewControllerAnimated:YES];
//}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)initSessionResults{
    
    self.title = [QZBSessionManager sessionManager].topic.name;
    
    self.firstUserName = [QZBSessionManager sessionManager].firstUserName;
    
    if ([QZBSessionManager sessionManager].opponentUserName) {
        self.opponentUserName = [QZBSessionManager sessionManager].opponentUserName;
    }
    
    if ([QZBSessionManager sessionManager].firstImageURL) {

        self.firstImageURL = [QZBSessionManager sessionManager].firstImageURL;
    }
    
    if ([QZBSessionManager sessionManager].opponentImageURL) {
        
        self.opponentImageURL = [QZBSessionManager sessionManager].opponentImageURL;
    }
    
    self.firstUserScore = [QZBSessionManager sessionManager].firstUserScore;
    
    self.secondUserScore = [QZBSessionManager sessionManager].secondUserScore;
    
    if (![QZBSessionManager sessionManager].isOfflineChallenge) {
        self.sessionResult = [QZBSessionManager sessionManager].sessionResult;
    } else {
        self.sessionResult = @"Ждем соперника";
    }
    
    self.topic = [QZBSessionManager sessionManager].topic;
    
    self.multiplier = [QZBSessionManager sessionManager].multiplier;
    
    self.beginScore = [QZBSessionManager sessionManager].userBeginingScore;
    
    self.endScore = self.beginScore + self.firstUserScore*self.multiplier;
    
    [[QZBSessionManager sessionManager] closeSession];

}

- (void)achievementGet:(NSNotification *)note {
    [self showAlertAboutAchievmentWithDict:note.object];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *mainCellIdentifier = @"endGameMainCell";
    static NSString *pointCellIdentifier = @"endGamePointsCell";
    static NSString *resultCellIdentifier = @"endGameResultPointsCell";
    static NSString *progressCellIdentifier = @"endGameProgressCell";
    
    UITableViewCell *cell = nil;
    if(indexPath.row == 0){
        QZBEndGameMainCell *mainCell = [tableView dequeueReusableCellWithIdentifier:mainCellIdentifier];
        
        [self initMainCell:mainCell];
        
        return mainCell;
    }else if(indexPath.row == 1){
        QZBEndGamePointsCell *pointsCell =
        [tableView dequeueReusableCellWithIdentifier:pointCellIdentifier];
        [pointsCell setCentralLabelWithNimber:self.multiplier];
        [pointsCell setScore:self.firstUserScore];
        return pointsCell;
    }else if(indexPath.row == 3){
        QZBEndGameResultScoreCell *resultScoreCell = [tableView dequeueReusableCellWithIdentifier:resultCellIdentifier];
        
        NSInteger result = self.firstUserScore * self.multiplier;
        [resultScoreCell setResultScore:result];
        return resultScoreCell;
    }else if (indexPath.row == 2){
        QZBEndGameProgressCell *progressCell =
        [tableView dequeueReusableCellWithIdentifier:progressCellIdentifier];
        //[progressCell initCell];
        if(!self.cellInited){
            self.cellInited = YES;
            [progressCell initCellWithBeginScore:self.beginScore];
        }
//        if(!self.progressShown){
//            self.progressShown = YES;
//            [progressCell initCell];
//            [progressCell moveProgressFromBeginScore:self.beginScore
//                                          toEndScore:self.endScore];
//        }
        
        return progressCell;
        
    }
    return cell;
    
}



#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row == 0){
        return 360;
    }else if(indexPath.row == 1||indexPath.row == 2||indexPath.row == 3) {
        return 150;
    }else{
        return 100;
    }
    
}

//- (void)checkVisibilityOfCell:(MyCustomUITableViewCell *)cell inScrollView:(UIScrollView *)aScrollView {
//    CGRect cellRect = [aScrollView convertRect:cell.frame toView:aScrollView.superview];
//    
//    if (CGRectContainsRect(aScrollView.frame, cellRect))
//        [cell notifyCompletelyVisible];
//    else
//        [cell notifyNotCompletelyVisible];
//}

-(BOOL)checkVisibilityOfCell:(UITableViewCell *)cell
                inScrollView:(UIScrollView *)scrollView{
    CGRect cellRect = [scrollView convertRect:cell.frame toView:scrollView.superview];
    return CGRectContainsRect(scrollView.frame, cellRect);
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    NSArray *cells = self.tableView.visibleCells;
    
    for(UITableViewCell *cell in cells){
        if([cell isKindOfClass:[QZBEndGameProgressCell class]]){
            if([self checkVisibilityOfCell:cell inScrollView:scrollView]){
                if(!self.progressShown){
                               self.progressShown = YES;
                QZBEndGameProgressCell *c = (QZBEndGameProgressCell *)cell;
                [c moveProgressFromBeginScore:self.beginScore
                                              toEndScore:self.endScore];
                }
            }
            
        }
        
    }
    
}



#pragma mark - cell init

-(void)initMainCell:(QZBEndGameMainCell *)cell{

    [cell initCell];
    
    cell.userNameLabel.text = self.firstUserName;
    
    if (self.opponentUserName) {
        cell.opponentNameLabel.text = self.opponentUserName;
    }
    
    if (self.firstImageURL) {
        [cell.userImage setImageWithURL:self.firstImageURL];
    }
    
    if (self.opponentImageURL) {
        [cell.opponentImage setImageWithURL:self.opponentImageURL];
    }
    
    
    
    cell.opponentBV.badgeText = [NSString
                                 stringWithFormat:@"%ld", (unsigned long)self.secondUserScore];
    cell.userBV.badgeText = [NSString
                             stringWithFormat:@"%ld", (unsigned long)self.firstUserScore];
    
    cell.resultOfSessionLabel.text = self.sessionResult;
    
}

- (BOOL)hidesBottomBarWhenPushed {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
