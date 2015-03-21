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

@interface QZBEndSessionControllerViewController ()

@end

@implementation QZBEndSessionControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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

    [[QZBSessionManager sessionManager] closeSession];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
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
