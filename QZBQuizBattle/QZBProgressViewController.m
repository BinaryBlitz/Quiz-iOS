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
#import "QZBOnlineSessionWorker.h"
#import "QZBSessionManager.h"
#import "QZBCurrentUser.h"
#import "QZBUser.h"
#import "QZBGameTopic.h"
#import "QZBServerManager.h"
#import "TSMessage.h"
#import <Pusher/Pusher.h>

@interface QZBProgressViewController ()<PTPusherDelegate>

@property(strong, nonatomic) QZBSession *session;
@property(strong, nonatomic) id bot;
@property(strong, nonatomic) QZBOnlineSessionWorker *onlineWorker;
@property(strong, nonatomic) QZBLobby *lobby;
@property(strong, nonatomic) NSTimer *timer;
@property(assign, nonatomic) NSUInteger counter;
@property(assign, nonatomic) BOOL isCanceled;
@property(assign, nonatomic) BOOL setted;
@property(assign, nonatomic) BOOL isOnline;
@property(assign, nonatomic) BOOL isEntered;

@property(strong, nonatomic) PTPusher *client;

@end

@implementation QZBProgressViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  // [[self navigationController] setNavigationBarHidden:YES animated:NO];
  // Do any additional setup after loading the view.
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(showGameVC:)
                                               name:@"QZBOnlineGameNeedStart"
                                             object:nil];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];

  // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  self.setted = NO;
  self.isCanceled = NO;
  self.isOnline = NO;
  self.isEntered = NO;
  
  self.onlineWorker = [[QZBOnlineSessionWorker alloc] init];

  [self initSession];
  //[self initBot];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [[self navigationController] setNavigationBarHidden:YES animated:NO];
  
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  
  
  [self.client disconnect];

  if (self.timer) {
    [self.timer invalidate];
    self.timer = nil;
  }

  [TSMessage dismissActiveNotification];
}

-(void)dealloc{
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
}

#pragma mark - Actions

- (IBAction)cancelFinding:(UIButton *)sender {
  self.isCanceled = YES;

  [[QZBSessionManager sessionManager] closeSession];
  [[QZBServerManager sharedManager] PATCHCloseLobby:self.lobby
                                          onSuccess:^(QZBSession *session, id bot) {
                                            
                                          } onFailure:^(NSError *error, NSInteger statusCode) {
                                            
                                          }];

  [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Navigation

#pragma mark - init session
// тестовая инициализация сессии
- (void)initSession {
  //__weak typeof(self) weakSelf = self;

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

  [[QZBServerManager sharedManager] POSTLobbyWithTopic:self.topic
      onSuccess:^(QZBLobby *lobby) {

        /*
        self.client =
        [PTPusher pusherWithKey:@"d982e4517caa41cf637c"
                       delegate:self encrypted:YES];
        
        [self.client connect];
        
        NSNumber *playerID = [QZBCurrentUser sharedInstance].user.user_id;
        
        NSString *channelName = [NSString stringWithFormat:@"player-start-%@",playerID];
        
        NSLog(@"channel name %@",channelName);
        
        PTPusherChannel *channel = [_client subscribeToChannelNamed:channelName];
        
        
        
        
        [channel bindToEventNamed:@"game-start" handleWithBlock:^(PTPusherEvent *channelEvent) {
          
          if(self.setted){
         [self performSegueWithIdentifier:@"showGame" sender:nil];
          }
          
        }];*/
        
        

        
          [self sessionFromLobby:lobby];

      }
      onFailure:^(NSError *error, NSInteger statusCode) {

          NSLog(@"failed");
          [TSMessage showNotificationWithTitle:@"Somthing went wrong"
                                          type:TSMessageNotificationTypeError];

      }];
}

- (void)sessionFromLobby:(QZBLobby *)lobby {
  if (lobby) {
    self.lobby = lobby;
  } else {
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

- (void)tryGetSession:(NSTimer *)timer {
  self.counter--;
  NSLog(@"%ld", (unsigned long)self.counter);

  [[QZBServerManager sharedManager] GETFindGameWithLobby:self.lobby
      onSuccess:^(QZBSession *session, id bot) {

        
            [self settitingSession:session bot:bot];
          
          if (self.timer != nil) {
            [self.timer invalidate];
            self.timer = nil;
          }

      }
      onFailure:^(NSError *error, NSInteger statusCode){

      }];

  if (self.counter == 0) {
    if (self.timer != nil) {
      [self.timer invalidate];
      self.timer = nil;
    }
  }
}

- (void)settitingSession:(QZBSession *)session bot:(id)bot {
  if(!self.setted){
    
    self.setted = YES;
  
  if (!self.isCanceled) {
    self.session = session;
    self.bot = bot;
  
    NSLog(@"setSession");
    [[QZBSessionManager sessionManager] setSession:self.session];
    
    if([bot isKindOfClass:[QZBOpponentBot class]]){
    
    [[QZBSessionManager sessionManager] setBot:(QZBOpponentBot *)self.bot];
      if(!self.isEntered){
        self.isEntered = YES;
      [self performSegueWithIdentifier:@"showGame" sender:nil];
      }
    }else {
      self.isOnline = YES;
      [[QZBSessionManager sessionManager] setOnlineSessionWorker:self.onlineWorker];
    }

    //[self performSegueWithIdentifier:@"showGame" sender:nil];
  }
  }
}


-(void)showGameVC:(NSNotification *)notification{
  if(self.setted && self.isOnline && !self.isEntered){
    self.isEntered = YES;
    [self performSegueWithIdentifier:@"showGame" sender:nil];
  }
}

@end
