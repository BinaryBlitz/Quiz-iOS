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
#import "NSTimer+Blocks.h"
//#import <Pusher/Pusher.h>

@interface QZBProgressViewController ()  //<PTPusherDelegate>

//@property(strong, nonatomic) QZBSession *session;
//@property(strong, nonatomic) id bot;
@property (strong, nonatomic) QZBOnlineSessionWorker *onlineWorker;
@property (strong, nonatomic) QZBLobby *lobby;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSUInteger counter;
@property (assign, nonatomic) BOOL isCanceled;
@property (assign, nonatomic) BOOL setted;
@property (assign, nonatomic) BOOL isOnline;
@property (assign, nonatomic) BOOL isEntered;

//@property(strong, nonatomic) PTPusher *client;

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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSubscribed:)
                                                 name:@"subscribedToChanel"
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    NSLog(@"showed progress VC");

    self.setted = NO;
    self.isCanceled = NO;
    self.isOnline = NO;
    self.isEntered = NO;
    self.lobby = nil;

    self.cancelButton.enabled = YES;

    if (!self.onlineWorker) {
        self.onlineWorker = [[QZBOnlineSessionWorker alloc] init];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    // [self.client disconnect];

    NSLog(@"progress disapear");

    self.lobby = nil;
    [self.timer invalidate];
    self.timer = nil;

    //[TSMessage dismissActiveNotification];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Actions

- (IBAction)cancelFinding:(UIButton *)sender {
    self.isCanceled = YES;

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

#pragma mark - Navigation

#pragma mark - init session
// тестовая инициализация сессии
- (void)initSession {
    __weak typeof(self) weakSelf = self;

    [[QZBServerManager sharedManager] POSTLobbyWithTopic:self.topic
        onSuccess:^(QZBLobby *lobby) {

          [weakSelf sessionFromLobby:lobby];

        }
        onFailure:^(NSError *error, NSInteger statusCode) {

          NSLog(@"failed");
            
            [self cancelFinding:nil];

        }];
}

- (void)sessionFromLobby:(QZBLobby *)lobby {
    if (lobby && !self.lobby) {
        self.lobby = lobby;
    } else {
        return;
    }
    self.counter = 7;
    __weak typeof(self) weakSelf = self;
    if (!self.timer) {
        /*
        _timer = [NSTimer scheduledTimerWithTimeInterval:2.0 block:^{
          id strongSelf = weakSelf;

          [strongSelf tryGetSession:nil];
        } repeats:YES];

        _timer = [NSTimer scheduledTimerWithTimeInterval:2.0 block:^{
          id strongSelf = weakSelf;

          [strongSelf tryGetSession:nil];
        } repeats:YES];
        */

        self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                      target:self
                                                    selector:@selector(tryGetSession:)
                                                    userInfo:nil
                                                     repeats:YES];

        [self tryGetSession:nil];
    }
}

- (void)tryGetSession:(NSTimer *)timer {
    if (![timer isEqual:self.timer]) {
        [timer invalidate];
        timer = nil;
    }

    if (_timer) {
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

            }];

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
            }

            //[self performSegueWithIdentifier:@"showGame" sender:nil];
        }
    }
}

- (void)showGameVC:(NSNotification *)notification {
    NSLog(@"setted %d online %d entered %d", self.setted, self.isOnline, self.isEntered);
    if (self.setted && self.isOnline && !self.isEntered) {
        self.cancelButton.enabled = NO;
        self.isEntered = YES;
        _onlineWorker = nil;

        [self performSegueWithIdentifier:@"showGame" sender:nil];
    }else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showGameVC:nil];
        });
    }
        
    
}

- (void)didSubscribed:(NSNotification *)notification {
    [self initSession];
}

@end
