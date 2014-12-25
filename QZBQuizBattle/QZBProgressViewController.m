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
  //[self initBot];

  self.myTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                  target:self
                                                selector:@selector(updateUI:)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)updateUI:(NSTimer *)timer {
  self.time++;

  if (self.time <= 10) {
    [self.progress setProgress:(float)self.time / 10 animated:YES];

  } else {
   // [self.myTimer invalidate];
  //  self.myTimer = nil;

   // [[QZBSessionManager sessionManager] setSession:self.session];
    //[[QZBSessionManager sessionManager] setBot:self.bot];

   // [self performSegueWithIdentifier:@"showGame" sender:nil];
  }
}

#pragma mark - Actions

- (IBAction)cancelFinding:(UIButton *)sender {
  
  [[QZBSessionManager sessionManager] closeSession];
  
  [self.myTimer invalidate];
  self.myTimer = nil;
  
  [self.navigationController popToRootViewControllerAnimated:YES];
  
}


#pragma mark - Navigation

#pragma mark - init session
// тестовая инициализация сессии
- (void)initSession {
  
  __weak typeof(self) weakSelf = self;
  
  [[QZBServerManager sharedManager] postSessionWithID:self.topic.topic_id
                                            onSuccess:^(QZBSession *session,QZBOpponentBot *bot) {
                                              weakSelf.session = session;
                                              weakSelf.bot = bot;
                                              [weakSelf.myTimer invalidate];
                                              weakSelf.myTimer = nil;
                                              
                                              [[QZBSessionManager sessionManager] setSession:weakSelf.session];
                                              [[QZBSessionManager sessionManager] setBot:self.bot];
                                              
                                              [weakSelf performSegueWithIdentifier:@"showGame" sender:nil];
                                              
                                              
    
  } onFailure:^(NSError *error, NSInteger statusCode) {
    
  }];
  [[QZBServerManager sharedManager] postSessionWithID:self.topic.topic_id onSuccess:nil onFailure:nil];
  
  /*
  NSArray *answers1 = @[ @"ни одной", @"1", @"2", @"3" ];

  QZBQuestion *
      question1 =
          [
              [QZBQuestion alloc] initWithTopic:@"CS"
                                       question:@"Сколько общих букв в "
                                                @"названии столиц Исландии и "
                                                @"Мальты?"
                                        answers:answers1
                                    rightAnswer:3];

  NSArray *answers2 = @[ @"5", @"4", @"6", @"7" ];

  QZBQuestion *question2 = [[QZBQuestion alloc] initWithTopic:@"CS"
                                                     question:@"Сколько "
                                                              @"слогов в "
                                                              @"названии "
                                                              @"столицы "
                                                              @"Мадагаскара?"
                                                      answers:answers2
                                                  rightAnswer:2];

  NSArray *answers3 = @[
    @"Гана и Эфиопия",
    @"Португалия и Венесуэла",
    @"Намибия и Эквадор",
    @"Финлянди и Филиппины"
  ];

  QZBQuestion *question3 = [[QZBQuestion alloc] initWithTopic:@"CS"
                                                     question:@"Названия "
                                                              @"столиц каких "
                                                              @"стран "
                                                              @"начинаются с "
                                                              @"одной и той "
                                                              @"же буквы?"
                                                      answers:answers3
                                                  rightAnswer:0];

  NSArray *answers4 = @[ @"Южная Корея", @"Катар", @"Фиджи", @"Мьянма" ];

  QZBQuestion *question4 = [[QZBQuestion alloc] initWithTopic:@"CS"
                                                     question:@"Название "
                                                              @"столицы "
                                                              @"какого из "
                                                              @"этих "
                                                              @"государств "
                                                              @"длиннее "
                                                              @"остальных?"
                                                      answers:answers4
                                                  rightAnswer:3];

  NSArray *answers5 = @[ @"Филиппины", @"Таджикистан", @"Сомали", @"Тунис" ];

  QZBQuestion *question5 = [[QZBQuestion alloc] initWithTopic:@"CS"
                                                     question:@"Название "
                                                              @"какого из "
                                                              @"этих "
                                                              @"государств "
                                                              @"короче "
                                                              @"названия его "
                                                              @"столицы?"
                                                      answers:answers5
                                                  rightAnswer:2];

  NSArray *answers6 = @[ @"Исламабад", @"Кито", @"Маскат", @"Вена" ];

  QZBQuestion *question6 = [[QZBQuestion alloc] initWithTopic:@"CS"
                                                     question:@"Столица "
                                                              @"государства, "
                                                              @"название "
                                                              @"которого "
                                                              @"начинается с "
                                                              @"согласной "
                                                              @"буквы"
                                                      answers:answers6
                                                  rightAnswer:0];
  
  NSArray *answers7 = @[@"Гватемала", @"Маршалловы острова",@"Сальвадор", @"Тонга"];
  
  QZBQuestion *question7 = [[QZBQuestion alloc] initWithTopic:@"CS"
                                                     question:@"Название какого из этих государств начинается не на ту же букву, что и его столица?"
                                                      answers:answers7
                                                  rightAnswer:3];
  
  NSArray *answers8 = @[@"ни одной", @"4",@"5", @"6"];
  
  QZBQuestion *question8 = [[QZBQuestion alloc] initWithTopic:@"CS"
                                                     question:@"Сколько букв в названии столицы Науру?"
                                                      answers:answers8
                                                  rightAnswer:0];
  
  NSArray *answers9 = @[@"Эстония", @"Иордания",@"Бангладеш", @"Мали"];
  
  QZBQuestion *question9 = [[QZBQuestion alloc] initWithTopic:@"CS"
                                                     question:@"У какого из этих государств столица не имеет в названии удвоенных согласных?"
                                                      answers:answers9
                                                  rightAnswer:3];
  

  NSArray *qestions =
      @[ question1, question2, question3, question4, question5, question6, question9 ];

  QZBUser *firstUser = [[QZBUser alloc] init];
  QZBUser *opponentUser = [[QZBUser alloc] init];*/

  /*self.session = [[QZBSession alloc] initWithQestions:qestions
                                                first:firstUser
                                         opponentUser:opponentUser];*/
}
/*
- (void)initBot {
  QZBAnswer *answer1 = [[QZBAnswer alloc] initWithAnswerNumber:0 answerTime:4];
  QZBAnswer *answer2 = [[QZBAnswer alloc] initWithAnswerNumber:1 answerTime:9];
  QZBAnswer *answer3 = [[QZBAnswer alloc] initWithAnswerNumber:2 answerTime:5];
  QZBAnswer *answer4 = [[QZBAnswer alloc] initWithAnswerNumber:3 answerTime:1];
  QZBAnswer *answer5 = [[QZBAnswer alloc] initWithAnswerNumber:2 answerTime:2];
  QZBAnswer *answer6 = [[QZBAnswer alloc] initWithAnswerNumber:1 answerTime:7];
  QZBAnswer *answer7 = [[QZBAnswer alloc] initWithAnswerNumber:2 answerTime:7];

  NSArray *answers = @[ answer1, answer2, answer3, answer4, answer5, answer6, answer7];

  self.bot = [[QZBOpponentBot alloc] initWithAnswersAndTimes:answers];
}*/

@end
