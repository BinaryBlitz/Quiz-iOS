//
//  QZBRoomResultTVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 25/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRoomResultTVC.h"
#import "QZBRoomUserResultCell.h"
#import "QZBUserWithTopic.h"
#import "QZBRoom.h"
#import "QZBRoomWorker.h"
#import "QZBSessionManager.h"
#import "UIViewController+QZBControllerCategory.h"

#import "QZBCategory.h"
#import "QZBGameTopic.h"

//controllers
#import "QZBRoomListTVC.h"


//dfiimage

#import <DFImageManager/DFImageManager.h>
#import <DFImageManager/DFImageRequestOptions.h>
#import <DFImageManager/DFURLImageFetcher.h>
#import <DFImageManager/DFImageRequest.h>
#import <DFImageManager/DFImageView.h>



//cell identifiers
NSString *const QZBRoomUserResultCellIdentifier = @"roomUserResultCellIdentifier";

@interface QZBRoomResultTVC()

//@property(strong, nonatomic) NSMutableArray *usersInResult;
@property(strong, nonatomic) QZBRoom *room;


@end

@implementation QZBRoomResultTVC


-(void)viewDidLoad{
    [super viewDidLoad];
    [self initStatusbarWithColor:[UIColor blackColor]];
    self.title = @"Результаты";
    
    [self configureBackgroundImage];
    [self backButtonInit];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    QZBRoom *room = [QZBSessionManager sessionManager].roomWorker.room;
    
    [self configureResultWithRoom:room];
    
    [[QZBSessionManager sessionManager] closeSession];
}

- (void)configureResultWithRoom:(QZBRoom *)room {
    self.room = room;
    
    [self.tableView reloadData];
}

#pragma mark - actions

-(void)leaveResults{
    
    NSArray *controllers = self.navigationController.viewControllers;
    UIViewController *destibnationController = nil;
    
    for(UIViewController *c in controllers){
        if([c isKindOfClass:[QZBRoomListTVC class]]) {
            destibnationController = c;
            break;
        }
    }
    [self.navigationController popToViewController:destibnationController animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.room.participants.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    QZBRoomUserResultCell *cell = [tableView dequeueReusableCellWithIdentifier:QZBRoomUserResultCellIdentifier];
    
    QZBUserWithTopic *userWithTopic = self.room.participants[indexPath.row];
    
    NSInteger position = indexPath.row + 1;
    
    [cell confirureWithUserWithTopic:userWithTopic position:@(position)];
    
    return cell;
    
}

#pragma mark - UITableViewDelegate

#pragma mark - support methods

-(void)configureBackgroundImage {
    
    QZBGameTopic *topic = [QZBSessionManager sessionManager].topic;
    
    QZBCategory *category = [[QZBServerManager sharedManager] tryFindRelatedCategoryToTopic:topic];
    if (category) {
        NSURL *url = [NSURL URLWithString:category.background_url];
        
        CGRect r = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds),
                              16 * CGRectGetWidth([UIScreen mainScreen].bounds) / 9);
        
        DFImageView *dfiIV = [[DFImageView alloc] initWithFrame:r];
        
        self.tableView.backgroundColor = [UIColor clearColor];
        
        DFImageRequestOptions *options = [DFImageRequestOptions new];
        options.allowsClipping = YES;
        
        options.userInfo = @{ DFURLRequestCachePolicyKey :
                                  @(NSURLRequestReturnCacheDataElseLoad)};
        //options.expirationAge = 60*60*24*10;
        
        DFImageRequest *request = [DFImageRequest requestWithResource:url
                                                           targetSize:CGSizeZero
                                                          contentMode:DFImageContentModeAspectFill
                                                              options:options];
        
        dfiIV.allowsAnimations = NO;
        dfiIV.allowsAutoRetries = YES;
        
        [dfiIV prepareForReuse];
        
        [dfiIV setImageWithRequest:request];
        
        
        self.tableView.backgroundView = dfiIV;
    }
    
}

- (void)backButtonInit {
    //   UIBarButtonItem *bbItem = [UIBarButtonItem alloc] initWithCustomView:
    UIBarButtonItem *logoutButton =
    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cancelCross"]
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(leaveResults)];
    
    self.navigationItem.leftBarButtonItem = logoutButton;
}

@end
