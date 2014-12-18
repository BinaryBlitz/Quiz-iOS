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



@interface QZBProgressViewController ()

@property(strong, nonatomic) QZBSession *session;

@end

@implementation QZBProgressViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  [self initSession];
  // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];

  // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  self.myTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                  target:self
                                                selector:@selector(updateUI:)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)updateUI:(NSTimer *)timer {
  
  static int count = 0;
  count++;

  NSLog(@"%d",count);
  if (count <= 10) {

    [self.progress setProgress:(float)count/10 animated:YES];
    
  } else {
    
    [self.myTimer invalidate];
    self.myTimer = nil;
    
    [[QZBSessionManager sessionManager] setSession:self.session];

    [self performSegueWithIdentifier:@"showGame" sender:nil];
  }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
// preparation before navigation
/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"showGame"]) {
    
    [[QZBSessionManager sessionManager] setSession:self.session];
    
   // controller.session = self.session;
  }
}*/

#pragma mark - init session
// тестовая инициализация сессии 
- (void)initSession {

  NSArray *answers1 = @[@"фил шиндлер", @"тим кук",@"ларри пейдж", @"стив возняк"];
  
  QZBQuestion *qestion1 = [[QZBQuestion alloc] initWithTopic:@"CS"
                                                    question:@"Кто был сооснователем эпл"
                                                    answers:answers1
                                                 rightAnswer:3];

  NSArray *answers2 = @[@"1", @"2",@"3", @"4"];
  
  QZBQuestion *qestion2 = [[QZBQuestion alloc] initWithTopic:@"CS"
                                                    question:@"3"
                                                     answers:answers2
                                                 rightAnswer:2];
  
  NSArray *answers3 = @[@"11", @"22",@"33", @"444"];
  
  QZBQuestion *qestion3 = [[QZBQuestion alloc] initWithTopic:@"CS"
                                                    question:@"444"
                                                     answers:answers3
                                                 rightAnswer:3];
  
  NSArray *qestions = @[qestion1,qestion2, qestion3];
  
  QZBUser *firstUser = [[QZBUser alloc] init];
  QZBUser *opponentUser = [[QZBUser alloc] init];
  
  self.session = [[QZBSession alloc] initWithQestions:qestions
                                                first:firstUser
                                         opponentUser:opponentUser];
  
  
}

@end
