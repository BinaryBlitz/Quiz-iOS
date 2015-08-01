//
//  QZBRatingMainVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 07/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRatingMainVC.h"
#import "QZBRatingPageVC.h"
#import "QZBCategory.h"
#import "QZBGameTopic.h"
#import "QZBServerManager.h"
#import "QZBPlayerPersonalPageVC.h"
#import <SVProgressHUD.h>
#import "UIViewController+QZBControllerCategory.h"
#import <DDLog.h>
static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface QZBRatingMainVC ()

@property (strong, nonatomic) id<QZBUserProtocol> user;
@property (assign, nonatomic) BOOL fromTopics;
//@property (strong, nonatomic) UIView *buttonBackgroundView;

@end

@implementation QZBRatingMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.multipleTouchEnabled = NO;
   // self.fromTopics = NO;
    
     [self setNeedsStatusBarAppearanceUpdate];

    [self.leftButton setExclusiveTouch:YES];
    [self.rightButton setExclusiveTouch:YES];
    [self.chooseTopicButton setExclusiveTouch:YES];
    
    [self initStatusbarWithColor:[UIColor whiteColor]];
    
    [self.rightButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.leftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
   // self.rightButton.titleLabel.textColor = [UIColor lightGreenColor];

    [self.sliderView removeConstraints:self.sliderView.constraints];
    self.sliderView.translatesAutoresizingMaskIntoConstraints = NO;

}


-(void)initWithTopic:(QZBGameTopic *)topic{
    
    self.fromTopics = YES;
    self.topic = topic;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setExclusiveTouch:YES];
    button.frame = CGRectMake(0,0,20, 20);
    [button setImage:[UIImage imageNamed:@"nextIcon"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showAnother:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
   // self.rightButton.titleLabel.textColor = [UIColor lightGrayColor];

    if (self.topic) {
        NSString *title = nil;
        
        if(self.fromTopics){
            title = self.topic.name;
            self.chooseTopicButton.enabled = NO;
            
             self.navigationItem.rightBarButtonItem = nil;
        }else{
            
           // self.navigationItem.rightBarButtonItem = nil;

            title = [NSString stringWithFormat:@"%@",self.topic.name];
        }
        
        [self.chooseTopicButton setTitle:title forState:UIControlStateNormal];
        
        [self setRatingWithTopicID:[self.topic.topic_id integerValue]];

    } else if (self.category) {
        NSString *title = [NSString stringWithFormat:@"%@",self.category.name ];
        
        [self.chooseTopicButton setTitle:title forState:UIControlStateNormal];

        [self setRatingWithCategoryID:[self.category.category_id integerValue]];

    } else {
        [self.chooseTopicButton setTitle:@"Все темы" forState:UIControlStateNormal];
        [self setRatingWithTopicID:0];
    }
    
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    //[self createButtonBackgroundView];

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
 //   [self.sliderView removeConstraints:self.sliderView.constraints];
    
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    //[self createButtonBackgroundView];
    [self addLineUnderButtons];
  //  NSLog(@"main layout");
}


- (void)setRatingWithCategoryID:(NSInteger)categoryID {
    QZBRatingPageVC *pageVC =
    (QZBRatingPageVC *)[self.childViewControllers firstObject];
    
    [self setEmptyArrays];
    [[QZBServerManager sharedManager]
        GETRankingWeekly:NO
              isCategory:YES
                  withID:categoryID
               onSuccess:^(NSArray *topRanking, NSArray *playerRanking) {
                   
                   [pageVC setAllTimeRanksWithTop:topRanking playerArray:playerRanking];
               }
     onFailure:^(NSError *error, NSInteger statusCode) {
         
     }];

    [[QZBServerManager sharedManager]
        GETRankingWeekly:YES
              isCategory:YES
                  withID:categoryID
               onSuccess:^(NSArray *topRanking, NSArray *playerRanking) {
                  

                   [pageVC setWeekRanksWithTop:topRanking playerArray:playerRanking];

               }
     onFailure:^(NSError *error, NSInteger statusCode) {
         
     }];
    
    
}

- (void)setRatingWithTopicID:(NSInteger)topicID {
    
    QZBRatingPageVC *pageVC =
    (QZBRatingPageVC *)[self.childViewControllers firstObject];
    [self setEmptyArrays];
    
    [[QZBServerManager sharedManager]
        GETRankingWeekly:NO
              isCategory:NO
                  withID:topicID
               onSuccess:^(NSArray *topRanking, NSArray *playerRanking) {
                   
                   [pageVC setAllTimeRanksWithTop:topRanking playerArray:playerRanking];

               }
     onFailure:^(NSError *error, NSInteger statusCode) {
         
     }];
    [[QZBServerManager sharedManager]
        GETRankingWeekly:YES
              isCategory:NO
                  withID:topicID
               onSuccess:^(NSArray *topRanking, NSArray *playerRanking) {

                   [pageVC setWeekRanksWithTop:topRanking playerArray:playerRanking];

               }
     onFailure:^(NSError *error, NSInteger statusCode) {
         
     }];
}

-(void)setEmptyArrays{
    QZBRatingPageVC *pageVC =
    (QZBRatingPageVC *)[self.childViewControllers firstObject];
    
    [pageVC setWeekRanksWithTop:[NSArray array] playerArray:[NSArray array]];
    [pageVC setAllTimeRanksWithTop:[NSArray array] playerArray:[NSArray array]];

}

#pragma mark - Navigation

- (void)showUserPage:(id<QZBUserProtocol>)user {
    self.user = user;
    [self performSegueWithIdentifier:@"showUser" sender:nil];

    DDLogInfo(@"destination user %@", [user name]);
}

// In a storyboard-based application, you will often want to do a little preparation before
// navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"showUser"]) {
//        if ([segue.destinationViewController isKindOfClass:[QZBPlayerPersonalPageVC class]]) {
//            //TEST
//        }

        QZBPlayerPersonalPageVC *vc = segue.destinationViewController;

        [vc initPlayerPageWithUser:self.user];
    }
}

#pragma mark - actions

-(void)showAnother:(id)sender{
    [self performSegueWithIdentifier:@"showCategories" sender:nil];
}

#pragma mark - page choose
- (IBAction)leftButtonAction:(UIButton *)sender {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                   });

    if ([[self.childViewControllers firstObject] isKindOfClass:[QZBRatingPageVC class]]) {
        QZBRatingPageVC *pageVC =
        (QZBRatingPageVC *)[self.childViewControllers firstObject];
        [pageVC showLeftVC];
    }
}

- (IBAction)rightButtonAction:(UIButton *)sender {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                   });

    if ([[self.childViewControllers firstObject] isKindOfClass:[QZBRatingPageVC class]]) {
        QZBRatingPageVC *pageVC = (QZBRatingPageVC *)[self.childViewControllers firstObject];
        [pageVC showRightVC];
    }
}

#pragma mark - ui init

-(void)addLineUnderButtons{
    UIBezierPath *path = [[UIBezierPath alloc] init];
    
    
    UIView *destView = self.buttonsBackgroundView.superview;
    
    CGRect mainR = [UIScreen mainScreen].bounds;
    CGRect r = destView.frame;
    
    CGPoint beginPoint = CGPointMake(r.size.height+r.origin.x-1, 0);
    CGPoint endPoint = CGPointMake(r.size.height+r.origin.x-1, mainR.size.width);
    
    [path moveToPoint:beginPoint];
    [path addLineToPoint:endPoint];
    
    
}

#pragma mark - lazy init

-(UIView *)buttonBackgroundView{
    if(_buttonBackgroundView){
        [self createButtonBackgroundView];
    }
    return _buttonBackgroundView;
}

-(void)createButtonBackgroundView{
    if(!_buttonBackgroundView){
        [self.buttonsBackgroundView setNeedsDisplay];
        CGSize backSize = self.buttonsBackgroundView.frame.size;
        NSLog(@"back size %f", backSize.width/2.0);
        CGRect r = CGRectMake(1, 1, backSize.width/2.0, 38);
        _buttonBackgroundView = [[UIView alloc] initWithFrame:r];
        
        _buttonBackgroundView.layer.cornerRadius = 5.0;
        _buttonBackgroundView.layer.masksToBounds = YES;
        _buttonBackgroundView.backgroundColor = [UIColor whiteColor];
        
        [_buttonsBackgroundView addSubview:_buttonBackgroundView];
        [_buttonsBackgroundView sendSubviewToBack:_buttonBackgroundView];
    }
}


-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}



@end
