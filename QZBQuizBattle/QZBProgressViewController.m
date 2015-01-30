//
//  QZBProgressViewController.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 13/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import "QZBProgressViewController.h"
#import "QZBGameSessionViewController.h"
#import "QZBLobby.h"
#import "QZBSession.h"
#import "QZBSessionManager.h"
#import "QZBUser.h"
#import "QZBGameTopic.h"
#import "QZBServerManager.h"
#import "TSMessage.h"

@interface QZBProgressViewController ()

@property(strong, nonatomic) QZBSession *session;
@property(strong, nonatomic) QZBOpponentBot *bot;
@property(strong, nonatomic) QZBLobby *lobby;
@property(strong, nonatomic) NSTimer *timer;
@property(assign, nonatomic) NSUInteger counter;
@property(assign, nonatomic) BOOL isCanceled;

@end

@implementation QZBProgressViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  // [[self navigationController] setNavigationBarHidden:YES animated:NO];
  // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];

  // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  NSLog(@"showed");

 
  self.isCanceled = NO;

  [self initSession];
  //[self initBot];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [[self navigationController] setNavigationBarHidden:YES animated:NO];
  
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];

  if(self.timer){
    [self.timer invalidate];
    self.timer = nil;
  }
  
  
  [TSMessage dismissActiveNotification];
}

#pragma mark - Actions

- (IBAction)cancelFinding:(UIButton *)sender {
  self.isCanceled = YES;

  [[QZBSessionManager sessionManager] closeSession];

  [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Navigation

#pragma mark - init session
// тестовая инициализация сессии
- (void)initSession {
  __weak typeof(self) weakSelf = self;

  NSLog(@"%@", self.topic);

  /*[[QZBServerManager sharedManager] postSessionWithTopic:self.topic
      onSuccess:^(QZBSession *session, QZBOpponentBot *bot) {
          if (!weakSelf.isCanceled) {
            weakSelf.session = session;
            weakSelf.bot = bot;
            NSLog(@"setSession");
            [[QZBSessionManager sessionManager] setSession:weakSelf.session];
            [[QZBSessionManager sessionManager] setBot:self.bot];

            [weakSelf performSegueWithIdentifier:@"showGame" sender:nil];
          };

      }
      onFailure:^(NSError *error, NSInteger statusCode) {

          NSLog(@"failed");
          [TSMessage showNotificationWithTitle:@"Somthing went wrong"
                                          type:TSMessageNotificationTypeError];

      }];*/
  
  [[QZBServerManager sharedManager] POSTLobbyWithTopic:self.topic onSuccess:^(QZBLobby *lobby) {
    
    [self sessionFromLobby:lobby];
    
    
    
  } onFailure:^(NSError *error, NSInteger statusCode) {
    
    NSLog(@"failed");
    [TSMessage showNotificationWithTitle:@"Somthing went wrong"
                                    type:TSMessageNotificationTypeError];
    
   

    
  }];
}

-(void)sessionFromLobby:(QZBLobby *)lobby{
  if(lobby){
    self.lobby = lobby;
  } else{
    return;
  }
  self.counter = 7;
  self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                   target:self
                                 selector:@selector(tryGetSession:)
                                 userInfo:nil
                                  repeats:YES];
  [self tryGetSession:nil];
  
  
}

-(void)tryGetSession:(NSTimer *)timer{
  
  
  self.counter--;
  NSLog(@"%ld",self.counter);
  
  [[QZBServerManager sharedManager] GETFindGameWithLobby:self.lobby
                                               onSuccess:^(QZBSession *session, QZBOpponentBot *bot) {
                                                 [self settitingSession:session bot:bot];
                                                 if(self.timer!=nil){
                                                   [self.timer invalidate];
                                                   self.timer = nil;
                                                 }
                                                 
                                               } onFailure:^(NSError *error, NSInteger statusCode) {
                                                 
                                               }];

  
  if(self.counter==0){
    if(self.timer!=nil){
      [self.timer invalidate];
      self.timer = nil;
    }
  }
}


-(void)settitingSession:(QZBSession *)session bot:(QZBOpponentBot *)bot{
  if (!self.isCanceled) {
    self.session = session;
    self.bot = bot;
    NSLog(@"setSession");
    [[QZBSessionManager sessionManager] setSession:self.session];
    [[QZBSessionManager sessionManager] setBot:self.bot];
    
    [self performSegueWithIdentifier:@"showGame" sender:nil];
  };

  
}

@end
