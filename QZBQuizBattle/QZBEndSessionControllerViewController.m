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

@interface QZBEndSessionControllerViewController ()

@end

@implementation QZBEndSessionControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)rematchAction:(UIButton *)sender {
  
  NSLog(@"rematch");
  NSArray *controllers = self.navigationController.viewControllers;
  
  UIViewController *destinationVC;
  
  for(UIViewController *controller in controllers){
    
    if([controller isKindOfClass:[QZBProgressViewController class]]){
      NSLog(@"%@",[controller class]);
      
      destinationVC = controller;
      break;
      
    }
  }
  [self.navigationController popToViewController:destinationVC animated:YES];
}


- (IBAction)ChooseTopicAction:(UIButton *)sender {
  [self.navigationController popToRootViewControllerAnimated:YES];
 }

@end
