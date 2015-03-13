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
#import "QZBCategory.h"
#import "QZBGameTopic.h"
#import "QZBServerManager.h"
#import "TSMessage.h"
//#import "NSTimer+Blocks.h"
//#import <Pusher/Pusher.h>

@interface QZBProgressViewController ()  <UIAlertViewDelegate>

//@property(strong, nonatomic) QZBSession *session;
//@property(strong, nonatomic) id bot;
@property (strong, nonatomic) QZBOnlineSessionWorker *onlineWorker;
@property (strong, nonatomic) QZBLobby *lobby;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSTimer *checkNeedStartTimer;
@property (assign, nonatomic) NSUInteger counter;
@property (assign, nonatomic) NSUInteger needStartCounter;
@property (assign, nonatomic) BOOL isCanceled;
@property (assign, nonatomic) BOOL setted;
@property (assign, nonatomic) BOOL isOnline;
@property (assign, nonatomic) BOOL isEntered;
//@property (assign, nonatomic) BOOL isManualHandling; //если не приходит пуш запускается мануальное управление

//@property(strong, nonatomic) PTPusher *client;

@end

@implementation QZBProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];

    // [[self navigationController] setNavigationBarHidden:YES animated:NO];
    // Do any additional setup after loading the view.

//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(showGameVC:)
//                                                 name:@"QZBOnlineGameNeedStart"
//                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(didSubscribed:)
//                                                 name:@"subscribedToChanel"
//                                               object:nil];
//    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    self.topicLabel.text = self.topic.name;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelCrossAction:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showGameVC:)
                                                 name:@"QZBOnlineGameNeedStart"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSubscribed:)
                                                 name:@"subscribedToChanel"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showAlertViewFromNotification:)
                                                 name:QZBPusherConnectionProblrms
                                               object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    NSLog(@"showed progress VC");

    self.setted = NO;
    self.isCanceled = NO;
    self.isOnline = NO;
    self.isEntered = NO;
    self.lobby = nil;
    self.checkNeedStartTimer = nil;

    self.cancelCrossButton.enabled = YES;

    if (!self.onlineWorker) {
        self.onlineWorker = [[QZBOnlineSessionWorker alloc] init];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // [self.client disconnect];
    
    NSLog(@"progress disapear");
    
    self.lobby = nil;
    [self.timer invalidate];
    self.timer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)initNavigationBar:(NSString *)title {
    self.navigationItem.hidesBackButton = YES;
    self.title = title;
    
}

-(void)setTopic:(QZBGameTopic *)topic{
    _topic = topic;
    
    NSLog(@"%@", topic.name);
    
    self.topicLabel.text = topic.name;
    
 //   topic.relationToCategory.name;
    
    [self initNavigationBar:topic.relationToCategory.name];
    
}


#pragma mark - Actions
- (IBAction)cancelCrossAction:(id)sender {
    
    self.isCanceled = YES;
    
    [self.checkNeedStartTimer invalidate];
    self.checkNeedStartTimer = nil;
    
    [self.onlineWorker closeConnection];
    self.onlineWorker = nil;
    
    [[QZBSessionManager sessionManager] closeSession];
    [[QZBServerManager sharedManager] PATCHCloseLobby:self.lobby
                                            onSuccess:^(QZBSession *session, id bot) {
                                                
                                            }
                                            onFailure:^(NSError *error, NSInteger statusCode){
                                                
                                            }];
    
    [self.navigationController popViewControllerAnimated:YES];

    
}

-(void)showAlertViewFromNotification:(NSNotification *)note{
    [[[UIAlertView alloc]initWithTitle:@"Ошибка связи"
                               message:@"Проверьте подключение к интернету"
                              delegate:self
                     cancelButtonTitle:@"Ок"
                     otherButtonTitles: nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;{
    
    if(buttonIndex == 0){
        [self cancelCrossAction:nil];
    }
    
}

#pragma mark - Navigation

#pragma mark - init session
// тестовая инициализация сессии
- (void)initSession {
    // __weak typeof(self) weakSelf = self;

    [[QZBServerManager sharedManager] POSTLobbyWithTopic:self.topic
        onSuccess:^(QZBLobby *lobby) {

            [self sessionFromLobby:lobby];

        }
        onFailure:^(NSError *error, NSInteger statusCode) {

           [[[UIAlertView alloc]initWithTitle:@"Ошибка связи"
                                      message:@"Проверьте подключение к интернету"
                                     delegate:self
                            cancelButtonTitle:@"Ок"
                            otherButtonTitles: nil] show];

            

        }];
}

- (void)sessionFromLobby:(QZBLobby *)lobby {
    if (lobby && !self.lobby) {
        self.lobby = lobby;
    } else {
        return;
    }
    self.counter = 7;
    // __weak typeof(self) weakSelf = self;
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                      target:self
                                                    selector:@selector(tryGetSession:)
                                                    userInfo:nil
                                                     repeats:YES];

        [self tryGetSession];
    }
}

- (void)tryGetSession:(NSTimer *)timer {
    if (_timer && [self.timer isEqual:timer]) {
        
        [self tryGetSession];

        if (_counter <= 0) {
            [_timer invalidate];
            _timer = nil;
        }
    } else {
        [timer invalidate];
        timer = nil;

        NSLog(@"problems");
    }
}

- (void)tryGetSession {
    _counter--;
    NSLog(@"%ld", (unsigned long)_counter);

    [[QZBServerManager sharedManager] GETFindGameWithLobby:_lobby
        onSuccess:^(QZBSession *session, id bot) {

            [self settitingSession:session bot:bot];

            [_timer invalidate];
            _timer = nil;

        }
        onFailure:^(NSError *error, NSInteger statusCode) {

            NSLog(@"finding failure");
            [self.navigationController popViewControllerAnimated:YES];

        }];
}

- (void)settitingSession:(QZBSession *)session bot:(id)bot {
    if (!self.setted && !self.isEntered) {
        self.setted = YES;

        if (!self.isCanceled) {
            NSLog(@"setSession");
            [[QZBSessionManager sessionManager] setSession:session];

            if ([bot isKindOfClass:[QZBOpponentBot class]]) {
                [[QZBSessionManager sessionManager] setBot:(QZBOpponentBot *)bot];
                if (!self.isEntered) {
                    self.isEntered = YES;
                    [self.onlineWorker closeConnection];
                    self.onlineWorker = nil;
                    [self performSegueWithIdentifier:@"showGame" sender:nil];
                }
            } else {
                self.isOnline = YES;
                [[QZBSessionManager sessionManager] setOnlineSessionWorker:self.onlineWorker];
                
                //not tested
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    
                    if([self checkCanEnterGame]){
                        NSLog(@"after func");
                        
                        [[[UIAlertView alloc]initWithTitle:@"Ошибка на сервере" message:@"Попробуйте еще раз" delegate:self cancelButtonTitle:@"Ок" otherButtonTitles: nil] show];
                        //[self showGameVC:nil];
                        
                        
                    }
                });
            }

            //[self performSegueWithIdentifier:@"showGame" sender:nil];
        }
    }
}

- (void)showGameVC:(NSNotification *)notification {
    NSLog(@"setted %d online %d entered %d", self.setted, self.isOnline, self.isEntered);

    if ([self checkCanEnterGame]) {
        NSLog(@"can enter");
        [self enterGame];
    } else {
        if (!self.checkNeedStartTimer) {
            NSLog(@"timer started");

            self.needStartCounter = 5;
            self.checkNeedStartTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                                        target:self
                                                                      selector:@selector(startGame:)
                                                                      userInfo:nil
                                                                       repeats:YES];
        }
    }
}

- (void)startGame:(NSTimer *)timer {
    NSLog(@"enter in start game function");

    if (self.checkNeedStartTimer && [timer isEqual:self.checkNeedStartTimer]) {
        if ([self checkCanEnterGame]) {
            NSLog(@"entered");

            [self.checkNeedStartTimer invalidate];
            self.checkNeedStartTimer = nil;
            [self enterGame];

        } else if (self.isEntered || self.isCanceled) {
            [self.checkNeedStartTimer invalidate];
            self.checkNeedStartTimer = nil;

        } else if (--self.needStartCounter <= 0 && !self.isEntered && !self.isCanceled) {
            [self.checkNeedStartTimer invalidate];
            self.checkNeedStartTimer = nil;

            [self.navigationController popViewControllerAnimated:YES];
        }
    }

    else {
        NSLog(@"bad timer invalidate in progress");
        [timer invalidate];
        timer = nil;
    }
}

- (BOOL)checkCanEnterGame {
    return self.setted && self.isOnline && !self.isEntered && !self.isCanceled;
}

- (void)enterGame {
    self.cancelCrossButton.enabled = NO;
    self.isEntered = YES;
    _onlineWorker = nil;
    [self.checkNeedStartTimer invalidate];
    [self performSegueWithIdentifier:@"showGame" sender:nil];
}

- (void)didSubscribed:(NSNotification *)notification {
    [self initSession];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
