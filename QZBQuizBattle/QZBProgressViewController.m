//
//  QZBProgressViewController.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 13/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import "QZBProgressViewController.h"
#import "QZBGameSessionViewController.h"
#import "QZBSession.h"
#import "QZBSessionManager.h"
#import "QZBUser.h"
#import "QZBGameTopic.h"
#import "QZBServerManager.h"

@interface QZBProgressViewController ()

@property(strong, nonatomic) QZBSession *session;
@property(strong, nonatomic) QZBOpponentBot *bot;
@property(assign, nonatomic) NSUInteger time;
@property(assign, nonatomic) BOOL isCanceled;

@end

@implementation QZBProgressViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];

  // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  NSLog(@"showed");

  self.time = 0;
  self.isCanceled = NO;

  [self initSession];
  //[self initBot];

 

}

#pragma mark - Actions

- (IBAction)cancelFinding:(UIButton *)sender {
  
  self.isCanceled = YES;
  
  [[QZBSessionManager sessionManager] closeSession];
  
  
  [self.navigationController popToRootViewControllerAnimated:YES];
  
}


#pragma mark - Navigation

#pragma mark - init session
// тестовая инициализация сессии
- (void)initSession {
  
  __weak typeof(self) weakSelf = self;
  
  NSLog(@"%@", self.topic);
  
  [[QZBServerManager sharedManager] postSessionWithID:self.topic.topic_id
                                            onSuccess:^(QZBSession *session,QZBOpponentBot *bot) {
                                              if(!weakSelf.isCanceled){
                                              
                                              weakSelf.session = session;
                                              weakSelf.bot = bot;
                                                NSLog(@"setSession");
                                              [[QZBSessionManager sessionManager] setSession:weakSelf.session];
                                              [[QZBSessionManager sessionManager] setBot:self.bot];
                                              
                                                [weakSelf performSegueWithIdentifier:@"showGame" sender:nil];};
                                              
                                              
    
  } onFailure:^(NSError *error, NSInteger statusCode) {
    
  }];
  

}


@end
