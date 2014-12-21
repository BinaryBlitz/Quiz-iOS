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
@property(strong, nonatomic) QZBOpponentBot *bot;
@property(assign, nonatomic) NSUInteger time;

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
  
  [self initSession];
  [self initBot];
  
  self.myTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                  target:self
                                                selector:@selector(updateUI:)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)updateUI:(NSTimer *)timer {
  
  self.time++;

  if (self.time <= 10) {

    [self.progress setProgress:(float)self.time/10 animated:YES];
    
  } else {
    
    [self.myTimer invalidate];
    self.myTimer = nil;
    
    
    [[QZBSessionManager sessionManager] setSession:self.session];
    [[QZBSessionManager sessionManager] setBot:self.bot];

    [self performSegueWithIdentifier:@"showGame" sender:nil];
  }
}

#pragma mark - Navigation



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

-(void)initBot{
  
  QZBAnswer *answer1 = [[QZBAnswer alloc] initWithAnswerNumber:3 answerTime:4];
  QZBAnswer *answer2 = [[QZBAnswer alloc] initWithAnswerNumber:2 answerTime:7];
  QZBAnswer *answer3 = [[QZBAnswer alloc] initWithAnswerNumber:3 answerTime:5];

  NSArray *answers = @[answer1, answer2,answer3];

  self.bot = [[QZBOpponentBot alloc] initWithAnswersAndTimes:answers];
}

@end
