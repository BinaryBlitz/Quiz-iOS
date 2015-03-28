//
//  QZBEndSessionControllerViewController.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 21/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import "QZBEndSessionControllerViewController.h"
#import "QZBGameTopic.h"
#import "QZBProgressViewController.h"
#import "QZBTopicChooserControllerViewController.h"
#import "QZBCategoryChooserVC.h"
#import "QZBSessionManager.h"
#import "UIViewController+QZBControllerCategory.h"
#import "UIViewController+QZBControllerCategory.h"
#import <UAProgressView.h>

@interface QZBEndSessionControllerViewController ()

@property(assign, nonatomic) NSInteger currentLevel;
//@property(assign, nonatomic) NSInteger beginLevel;
@property(assign, nonatomic) NSInteger resultLevel;
@property(assign, nonatomic) float resultProgress;


@end

@implementation QZBEndSessionControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = nil;
    
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    self.tabBarController.tabBar.hidden = NO;
    
    if(![QZBSessionManager sessionManager].isOfflineChallenge){
        self.title = [QZBSessionManager sessionManager].sessionResult;
    }
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    //[[self navigationController] setNavigationBarHidden:YES animated:NO];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(achievementGet:)
                                                 name:@"QZBAchievmentGet"
                                               object:nil];

    self.firstUserScore.text = [NSString
        stringWithFormat:@"%lu", (unsigned long)[QZBSessionManager sessionManager].firstUserScore];

    self.opponentUserScore.text = [NSString
        stringWithFormat:@"%lu", (unsigned long)[QZBSessionManager sessionManager].secondUserScore];

   
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //[[QZBSessionManager sessionManager] closeSession];
    
    [self movingProgress];
    
    
    
    [[QZBSessionManager sessionManager] closeSession];
    
}

-(void)movingProgress{
    
 //   __weak typeof(self)weakSelf = self;
    
//    [self.circularProgress setProgressChangedBlock:^(UAProgressView *progressView, float progress) {
//        
//        if(progress == 0.9999){
//            progress = 0.0;
//            progressView.progress = progress;
//        }
//        if(progress == 0){
//            
//            UILabel *centralLabel = (UILabel *)progressView.centralView;
//            
//            if(weakSelf.currentLevel<weakSelf.resultLevel){
//                centralLabel.text = [NSString stringWithFormat:@"%ld", weakSelf.currentLevel];
//                weakSelf.currentLevel++;
//            }
//            
//            if(weakSelf.currentLevel >= weakSelf.resultLevel){
//                [progressView setProgress:weakSelf.resultProgress animated:YES];
//            }
//        }
//    }];
    
    
    NSInteger beginScore = [QZBSessionManager sessionManager].userBeginingScore;
    NSUInteger gettedScore = [QZBSessionManager sessionManager].firstUserScore;
    
    NSInteger newScore = beginScore+gettedScore;
    
    NSInteger beginLevel = 0;
    float beginProgress = 0.0;
    NSInteger resultLevel = 0;
    float resultProgress = 0.0;
    
    
    [self calculateLevel:&beginLevel
           levelProgress:&beginProgress
               fromScore:beginProgress];
    
    self.circularProgress.centralView = [self labelForNum:beginLevel
                                                   inView:self.circularProgress];
    
    [self.circularProgress setProgress:beginProgress
                              animated:NO];
    
    [self calculateLevel:&resultLevel
           levelProgress:&resultProgress
               fromScore:newScore];
    
    self.resultLevel = resultLevel;
    self.currentLevel = beginLevel;
    self.resultProgress = resultProgress;
    
    [self turningCircularView];
    
    
    
    
    
  //  float needProgress = (float)(resultLevel-beginLevel)+resultProgress-beginProgress;
    
    
//    if(beginLevel == resultLevel){
//        [self.circularProgress setProgress:resultProgress
//                                  animated:YES];
//    }else{
//        [self.circularProgress setProgress:0.9999 animated:YES];
//    }
    
    
}


-(void)turningCircularView{
    
    if(self.currentLevel == self.resultLevel){
        [self.circularProgress setProgress:self.resultProgress animated:YES];
    }
    
    if(self.currentLevel<self.resultLevel){
        [self.circularProgress setProgress:0.9999 animated:YES];
        CFTimeInterval time = self.circularProgress.animationDuration+0.1;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            self.circularProgress.progress = 0.0;
            self.currentLevel++;
            [self turningCircularView];
            
        });
       // self.currentLevel++;
    }
    
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)achievementGet:(NSNotification *)note {
    
    [self showAlertAboutAchievmentWithDict:note.object];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)rematchAction:(UIButton *)sender {
    [self moveToVCWithClass:[QZBProgressViewController class]];
}

- (IBAction)ChooseTopicAction:(UIButton *)sender {
    [self moveToVCWithClass:[QZBTopicChooserControllerViewController class]];
    //[self.navigationController popToRootViewControllerAnimated:YES];
}
- (IBAction)chooseCategoryAction:(id)sender {
    [self moveToVCWithClass:[QZBCategoryChooserVC class]];
}

- (void)moveToVCWithClass:(__unsafe_unretained Class)VCclass {
    NSArray *controllers = self.navigationController.viewControllers;

    UIViewController *destinationVC;

    for (UIViewController *controller in controllers) {
        if ([controller isKindOfClass:VCclass]) {
            NSLog(@"%@", [controller class]);

            destinationVC = controller;
            break;
        }
    }
    if (!destinationVC) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.navigationController popToViewController:destinationVC animated:YES];
    }
}

@end
