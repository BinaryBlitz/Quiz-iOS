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

@interface QZBRatingMainVC ()

@property (strong, nonatomic) id<QZBUserProtocol> user;
@property (assign, nonatomic) BOOL fromTopics;

@end

@implementation QZBRatingMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.multipleTouchEnabled = NO;
   // self.fromTopics = NO;
    
     [self setNeedsStatusBarAppearanceUpdate];
    
    //barButtonName.title = @"SOME TEXT TO DISPLAY";
    NSUInteger size = 18;
    UIFont * font = [UIFont boldSystemFontOfSize:size];
    NSDictionary * attributes = @{NSFontAttributeName: font};
    [self.leftButton setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [self.rightButton setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    [self initStatusbarWithColor:[UIColor whiteColor]];
    
//    [self.navigationController.navigationBar setBackIndicatorImage:[UIImage imageNamed:@"backWhiteIcon"]];
//    [self.navigationController.navigationBar setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"backWhiteIcon"]];
    
//    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
//    [self.navigationController.navigationBar
//     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
//

    // self.rightButton.
    // Do any additional setup after loading the view.
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
    
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:nil
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(showAnother:)];
    self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"nextIcon"];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
   

    
   // [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
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
        
       // [NSString stringWithFormat:@"%@ >",self.topic.name];
        
        [self.chooseTopicButton setTitle:title forState:UIControlStateNormal];
        
        //[self.chooseTopicButton setTitle:self.topic.name forState:UIControlStateNormal];

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
//
    
}

- (void)setRatingWithCategoryID:(NSInteger)categoryID {
    [[QZBServerManager sharedManager]
        GETRankingWeekly:NO
              isCategory:YES
                  withID:categoryID
               onSuccess:^(NSArray *topRanking, NSArray *playerRanking) {

                   QZBRatingPageVC *pageVC =
                       (QZBRatingPageVC *)[self.childViewControllers firstObject];
                   [pageVC setAllTimeRanksWithTop:topRanking playerArray:playerRanking];

               }
               onFailure:nil];

    [[QZBServerManager sharedManager]
        GETRankingWeekly:YES
              isCategory:YES
                  withID:categoryID
               onSuccess:^(NSArray *topRanking, NSArray *playerRanking) {
                   QZBRatingPageVC *pageVC =
                       (QZBRatingPageVC *)[self.childViewControllers firstObject];

                   [pageVC setWeekRanksWithTop:topRanking playerArray:playerRanking];

               }
               onFailure:nil];
}

- (void)setRatingWithTopicID:(NSInteger)topicID {
    [[QZBServerManager sharedManager]
        GETRankingWeekly:NO
              isCategory:NO
                  withID:topicID
               onSuccess:^(NSArray *topRanking, NSArray *playerRanking) {
                   QZBRatingPageVC *pageVC =
                       (QZBRatingPageVC *)[self.childViewControllers firstObject];
                   [pageVC setAllTimeRanksWithTop:topRanking playerArray:playerRanking];

               }
               onFailure:nil];
    [[QZBServerManager sharedManager]
        GETRankingWeekly:YES
              isCategory:NO
                  withID:topicID
               onSuccess:^(NSArray *topRanking, NSArray *playerRanking) {
                   QZBRatingPageVC *pageVC =
                       (QZBRatingPageVC *)[self.childViewControllers firstObject];

                   [pageVC setWeekRanksWithTop:topRanking playerArray:playerRanking];

               }
               onFailure:nil];
}

#pragma mark - Navigation

- (void)showUserPage:(id<QZBUserProtocol>)user {
    self.user = user;
    [self performSegueWithIdentifier:@"showUser" sender:nil];

    NSLog(@"destination user %@", [user name]);
}

// In a storyboard-based application, you will often want to do a little preparation before
// navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    if ([segue.identifier isEqualToString:@"showUser"]) {
        if ([segue.destinationViewController isKindOfClass:[QZBPlayerPersonalPageVC class]]) {
            NSLog(@"YES");
        }

        QZBPlayerPersonalPageVC *vc = segue.destinationViewController;

        [vc initPlayerPageWithUser:self.user];
    }
}

#pragma mark - actions

-(void)showAnother:(id)sender{
    [self performSegueWithIdentifier:@"showCategories" sender:nil];
}

#pragma mark - page choose
- (IBAction)leftButtonAction:(UIBarButtonItem *)sender {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                   });

    if ([[self.childViewControllers firstObject] isKindOfClass:[QZBRatingPageVC class]]) {
        QZBRatingPageVC *pageVC = (QZBRatingPageVC *)[self.childViewControllers firstObject];
        [pageVC showLeftVC];
    }
}

- (IBAction)rightButtonAction:(UIBarButtonItem *)sender {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                   });

    if ([[self.childViewControllers firstObject] isKindOfClass:[QZBRatingPageVC class]]) {
        QZBRatingPageVC *pageVC = (QZBRatingPageVC *)[self.childViewControllers firstObject];
        [pageVC showRightVC];
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
