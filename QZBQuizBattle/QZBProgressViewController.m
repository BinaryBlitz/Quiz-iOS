//
//  QZBProgressViewController.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 13/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import "QZBProgressViewController.h"
#import "QZBGameSessionViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "CoreData+MagicalRecord.h"
#import "QZBLobby.h"
#import "QZBSession.h"
#import "QZBOnlineSessionWorker.h"
#import "QZBSessionManager.h"
#import "QZBCurrentUser.h"
#import "QZBUser.h"
#import "QZBChallengeDescription.h"
#import "QZBCategory.h"
#import "QZBGameTopic.h"
#import "QZBServerManager.h"
#import "TSMessage.h"
#import "QZBTopicWorker.h"
#import <DDLog.h>
#import <SVIndefiniteAnimatedView.h>
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
//#import "FXBlurView.h"

@interface QZBProgressViewController () <UIAlertViewDelegate>

@property (strong, nonatomic) id<QZBUserProtocol> user;
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
@property (strong, nonatomic) NSNumber *lobbyNumber;  // for accept challenges
@property (assign, nonatomic) BOOL alertShown;

//@property (assign, nonatomic) BOOL isManualHandling; //если не приходит пуш запускается мануальное
//управление
//показывается уведомление об ошибках на сервере

//@property(strong, nonatomic) PTPusher *client;

@end

@implementation QZBProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setNeedsStatusBarAppearanceUpdate];

    self.playOfflineButton.alpha = 0;
    
//    self.animationView = [[SVIndefiniteAnimatedView alloc] initWithFrame:self.backView.bounds];
//    self.animationView.strokeThickness = 1.0;
//    self.animationView.strokeColor = [UIColor redColor];
//    self.animationView.radius = 60.0;
//    
//    [self.backView addSubview:self.animationView];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"QZBDoNotNeedShowMessagerNotifications"
                                                        object:nil];

    self.topicLabel.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.topicLabel.layer.shadowOffset = CGSizeMake(2.0, 2.0);
    self.topicLabel.layer.shadowRadius = 2.0;
    self.topicLabel.layer.shadowOpacity = 0.5;
    
    QZBCategory *category =
        [QZBTopicWorker tryFindRelatedCategoryToTopic:self.topic];
    if (category) {
       
        //[self initNavigationBar:topic.relationToCategory.name];
        [self initScreenWithCategory:category];
    }

    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    self.topicLabel.text = self.topic.name;
    self.tabBarController.tabBar.hidden = YES;
    

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cancelCrossAction:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cancelCrossAction:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];

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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showAlertViewFromNotification:)
                                                 name:QZBPusherChallengeDeclined
                                               object:nil];
    
    //[self initWhiteViewOn:self.backgroundImageView];

    [self addSpinner];
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
   // [self initWhiteViewOn:self.backgroundImageView];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
  //  self.animationView.center = self.backView.center;
 //   [self initWhiteViewOn:self.backgroundImageView];
 //   [self initBlurEffect];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    DDLogInfo(@"showed progress VC");
    self.tabBarController.tabBar.hidden = YES;

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
    
  //  [self addSpinner];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [self.animationView removeFromSuperview];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    // [self.client disconnect];
     [[NSNotificationCenter defaultCenter] postNotificationName:@"QZBNeedShowMessagerNotifications"
                                                         object:nil];

    DDLogInfo(@"progress disapear");

    self.isChallenge = NO;
    self.lobby = nil;
    [self.timer invalidate];
    self.timer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    //[self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)initNavigationBar:(NSString *)title {
    self.navigationItem.hidesBackButton = YES;
    self.title = title;
}

- (void)initScreenWithCategory:(QZBCategory *)category {
    if (category) {
        [self initNavigationBar:category.name];

        NSURL *url = [NSURL URLWithString:category.background_url];
        NSURLRequest *imageRequest =
            [NSURLRequest requestWithURL:url
                             cachePolicy:NSURLRequestReturnCacheDataElseLoad
                         timeoutInterval:60];
        //   UIImage *image = [[UIImage alloc] init];

        [self.backgroundImageView
            setImageWithURLRequest:imageRequest
                  placeholderImage:nil
                           success:nil
                           failure:nil];
       // [self.view sendSubviewToBack:self.backgroundImageView];
    }
}

- (void)setTopic:(QZBGameTopic *)topic {
    _topic = topic;

    DDLogInfo(@"%@", topic.name);

    self.topicLabel.text = topic.name;

    [[QZBSessionManager sessionManager] setTopicForSession:topic];

}

#pragma mark - custom init

- (void)initSessionWithDescription:(QZBChallengeDescription *)description {
    self.topic = description.topic;
    self.isChallenge = YES;
    self.lobbyNumber = description.lobbyID;
}

- (void)initSessionWithTopic:(QZBGameTopic *)topic user:(id<QZBUserProtocol>)user {
    self.topic = topic;
    if (user) {
        DDLogInfo(@"user exist in progress");
        self.user = user;
        //  self.playOfflineButton.alpha = 1.0;
    } else {
        //  self.playOfflineButton.alpha = 0;
        self.playOfflineButton.enabled = NO;
    }
}

#pragma mark - Actions
- (IBAction)cancelCrossAction:(id)sender {
    [self closeFinding];

    [[QZBServerManager sharedManager] PATCHCloseLobby:self.lobby
        onSuccess:^(QZBSession *session, id bot) {

        }
        onFailure:^(NSError *error, NSInteger statusCode){

        }];

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)closeFinding {
    self.isCanceled = YES;

    [self.checkNeedStartTimer invalidate];
    self.checkNeedStartTimer = nil;

    [self.onlineWorker closeConnection];
    self.onlineWorker = nil;

    [[QZBSessionManager sessionManager] closeSession];
}

- (void)showAlertViewFromNotification:(NSNotification *)note {
    if ([note.object isKindOfClass:[NSArray class]]) {
        NSArray *description = note.object;

        if(!self.alertShown){
            self.alertShown = YES;
        [[[UIAlertView alloc] initWithTitle:description[0]
                                    message:description[1]
                                   delegate:self
                          cancelButtonTitle:@"Ок"
                          otherButtonTitles:nil] show];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (buttonIndex == 0) {
        [self cancelCrossAction:nil];
    }
}
- (IBAction)playOfflineAction:(id)sender {
    [[QZBSessionManager sessionManager] removeBotOrOnlineWorker];
    [self enterGame];
}


#pragma mark - init session

- (void)initSession {
    if (self.isChallenge) {
        [[QZBServerManager sharedManager] POSTAcceptChallengeWhithLobbyID:self.lobbyNumber
            onSuccess:^(QZBSession *session, QZBOpponentBot *bot) {

                [self settitingSession:session bot:bot];

            }
            onFailure:^(NSError *error, NSInteger statusCode){
                [self showAlertServerProblem];

            }];
    } else if (!self.user) {
        [[QZBServerManager sharedManager] POSTLobbyWithTopic:self.topic
            onSuccess:^(QZBLobby *lobby) {

                [self sessionFromLobby:lobby];

            }
            onFailure:^(NSError *error, NSInteger statusCode){
                [self showAlertServerProblem];

            }];
    } else if (!self.isChallenge) {
        [[QZBServerManager sharedManager] POSTLobbyChallengeWithUserID:self.user.userID
            inTopic:self.topic
            onSuccess:^(QZBSession *session) {

                [self setFactWithString:session.fact];
                
                QZBLobby *lobby =
                    [[QZBLobby alloc] initWithLobbyID:[session.lobbyID integerValue]
                                              topicID:[self.topic.topic_id integerValue]
                                             playerID:[self.user.userID integerValue]
                                           queryCount:0];
                self.lobby = lobby;

                [self settitingSession:session
                                   bot:nil];

                [UIView animateWithDuration:0.4
                    delay:5
                    options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{

                        self.playOfflineButton.alpha = 1.0;

                    }
                    completion:^(BOOL finished) {

                        self.playOfflineButton.enabled = YES;

                    }];

               // self.playOfflineButton.alpha = 1.0;//??

            }
            onFailure:^(NSError *error, NSInteger statusCode){
                
                //if(!error && statusCode == -1){
                    [self showAlertServerProblem];
              //  }
            }];
    } else {
    }
}

-(void)showAlertServerProblem{
    [[[UIAlertView alloc]
      initWithTitle:@"Ошибка на сервере"
      message:@"Попробуйте еще раз"
      delegate:self
      cancelButtonTitle:@"Ок"
      otherButtonTitles:nil] show];
}

- (void)sessionFromLobby:(QZBLobby *)lobby {
    if (lobby && !self.lobby) {
        self.lobby = lobby;
        
        [self setFactWithString:lobby.fact];
    } else {
        return;
    }
    self.counter = 7;

    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.4
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

        DDLogInfo(@"problems");
    }
}

- (void)tryGetSession {
    _counter--;
    DDLogInfo(@"%ld", (unsigned long)_counter);

    [[QZBServerManager sharedManager] GETFindGameWithLobby:_lobby
        onSuccess:^(QZBSession *session, id bot) {

            [self settitingSession:session bot:bot];

            [_timer invalidate];
            _timer = nil;

        }
        onFailure:^(NSError *error, NSInteger statusCode) {

            DDLogInfo(@"finding failure");
            [self.navigationController popViewControllerAnimated:YES];

        }];
}

- (void)settitingSession:(QZBSession *)session bot:(id)bot {
    if (!self.setted && !self.isEntered) {
        self.setted = YES;

        if (!self.isCanceled) {
            DDLogInfo(@"setSession");
            [[QZBSessionManager sessionManager] setSession:session];
            if(self.isChallenge || self.user){
                [[QZBSessionManager sessionManager] setIsChallenge:YES];
            }
            

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
                [[QZBSessionManager sessionManager] setOnlineSessionWorkerFromOutside:self.onlineWorker];

                if (!self.user && self.isChallenge) {
                    dispatch_after(
                        dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)),
                        dispatch_get_main_queue(), ^{

                            if ([self checkCanEnterGame]) {
                                DDLogWarn(@"after func");

                                [[[UIAlertView alloc]
                                        initWithTitle:@"Ошибка на сервере"
                                              message:@"Попробуйте еще раз"
                                             delegate:self
                                    cancelButtonTitle:@"Ок"
                                    otherButtonTitles:nil] show];
                            }
                        });
                }
            }
        }
    }
}

#pragma mark - enter game

- (void)showGameVC:(NSNotification *)notification {
    DDLogInfo(@"setted %d online %d entered %d", self.setted, self.isOnline, self.isEntered);

    if ([self checkCanEnterGame]) {
        DDLogInfo(@"can enter");
        [self enterGame];
    } else {
        if (!self.checkNeedStartTimer) {
            DDLogInfo(@"timer started");

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
    DDLogInfo(@"enter in start game function");

    if (self.checkNeedStartTimer && [timer isEqual:self.checkNeedStartTimer]) {
        if ([self checkCanEnterGame]) {
            DDLogInfo(@"entered");

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
        DDLogWarn(@"bad timer invalidate in progress");
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

-(void)initWhiteViewOn:(UIView *)view{
    CGRect r = [UIScreen mainScreen].bounds;
    
    //FXBlurView *vi = [[FXBlurView alloc] initWithFrame:r];
   // vi.dynamic = YES;
   // vi.blurRadius = 0.9;
   // vi.iterations = 12;
    
    
    //[UIColor colorWithWhite:1.0 alpha:0.1];
    UIView *vi = [[UIView alloc] initWithFrame:r];
    vi.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    [view addSubview:vi];
    [view sendSubviewToBack:vi];
    
  //  [view setNeedsDisplay];
}

-(void)addSpinner {
    
    
//    self.animationView = [[SVIndefiniteAnimatedView alloc]
//                          init];
//    
//    
//    [self.backView addSubview:self.animationView];
//    
//    [self.animationView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-5-[animationView]-5-|" options:0 metrics:nil views:@{@"animationView":self.animationView}]];
//    
//    [self.animationView addConstraint:[NSLayoutConstraint constraintWithItem:self.animationView attribute:NSLayoutAttributeLeft|
//                                      NSLayoutAttributeRight|
//                                      NSLayoutAttributeTop|
//                                       NSLayoutAttributeBottom relatedBy: NSLayoutRelationEqual toItem:self.backView attribute:NSLayoutAttributeLeading|
//                                       NSLayoutAttributeTrailing multiplier:1.0 constant:-8]];
    
    
    //self.backView = [[SVIndefiniteAnimatedView alloc] initWithFrame:self.backView.frame];
    
   // CGRectMake(0, 0, 50, 50);
 //   CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
//    CGRect r = [UIScreen mainScreen].bounds;
  //  self.animationView = [[SVIndefiniteAnimatedView alloc]
  //                        initWithFrame:CGRectMake(0, 0, 50, 50)];
//    self.animationView.strokeThickness = 2.0;
//    self.animationView.strokeColor = [UIColor redColor];
//    self.animationView.radius = 25.0;
    
 //   self.animationView.alpha = 0.0;
    
    //[self.backView addSubview:self.animationView];
  //  [self.view bringSubviewToFront:self.animationView];
    //self.backView.backgroundColor = [UIColor clearColor];
//    self.animationView.center = self.backView.center;
//    [UIView animateWithDuration:0.1 animations:^{
//        self.animationView.alpha = 1.0;
//    }];
    
    self.animationView = [[SVIndefiniteAnimatedView alloc]
                          initWithFrame:CGRectMake(0, 0, 60, 60)];
    
    self.animationView.strokeThickness = 2.0;
    self.animationView.strokeColor = [UIColor redColor];
    self.animationView.radius = 25.0;
    
    [self.backView addSubview:self.animationView];
    
    self.animationView.translatesAutoresizingMaskIntoConstraints = NO;
  
//    [self.backView addConstraint:[NSLayoutConstraint constraintWithItem:self.animationView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f]];
//    [self.backView addConstraint:[NSLayoutConstraint constraintWithItem:self.animationView  attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f]];
//    [self.backView addConstraint:[NSLayoutConstraint constraintWithItem:self.animationView  attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0f constant:0.0f]];
//    [self.backView addConstraint:[NSLayoutConstraint constraintWithItem:self.animationView  attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f]];
    UIView *redView  = self.animationView;
//    [self.backView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[redView]|"
//                                                                      options:NSLayoutFormatAlignAllCenterX | NSLayoutFormatAlignAllCenterY
//                                                                      metrics:nil
//                                                                        views:NSDictionaryOfVariableBindings(redView)]];
    [self.backView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=0)-[redView(==60)]-(>=0)-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(redView)]];
    [self.backView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[redView(==60)]-(>=0)-|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(redView)]];
    
}

#pragma mark - support method

-(void)setFactWithString:(NSString *)fact{
    
    self.factLabel.text = fact;
    
    [UIView animateWithDuration:0.4 animations:^{
        self.factLabel.superview.alpha = 1.0;
    }];
    
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
