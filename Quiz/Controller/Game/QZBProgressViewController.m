#import "QZBProgressViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "MagicalRecord/MagicalRecord.h"
#import "QZBLobby.h"
#import "QZBSession.h"
#import "QZBOnlineSessionWorker.h"
#import "QZBSessionManager.h"
#import "QZBChallengeDescription.h"
#import "QZBCategory.h"
#import "QZBGameTopic.h"
#import "QZBTopicWorker.h"
#import <DDLog.h>
#import <SVIndefiniteAnimatedView.h>

static const int ddLogLevel = LOG_LEVEL_VERBOSE;
//#import "FXBlurView.h"

@interface QZBProgressViewController () <UIAlertViewDelegate>

@property (strong, nonatomic) id <QZBUserProtocol> user;
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

@property (assign, nonatomic) BOOL isPlayAgain;

@end

@implementation QZBProgressViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  [self setNeedsStatusBarAppearanceUpdate];

  self.playOfflineButton.alpha = 0;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [[NSNotificationCenter defaultCenter]
      postNotificationName:@"QZBDoNotNeedShowMessagerNotifications"
                    object:nil];

  self.topicLabel.layer.shadowColor = [UIColor lightGrayColor].CGColor;
  self.topicLabel.layer.shadowOffset = CGSizeMake(2.0, 2.0);
  self.topicLabel.layer.shadowRadius = 2.0;
  self.topicLabel.layer.shadowOpacity = 0.5;

  QZBCategory *category = [QZBTopicWorker tryFindRelatedCategoryToTopic:self.topic];
  if (category) {
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

  [self addSpinner];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  DDLogInfo(@"showed progress VC");

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

- (void)viewDidDisappear:(BOOL)animated {
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

    [self.backgroundImageView setImageWithURLRequest:imageRequest
                                    placeholderImage:nil
                                             success:nil
                                             failure:nil];
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

- (void)initSessionWithTopic:(QZBGameTopic *)topic user:(id <QZBUserProtocol>)user {
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

- (void)initPlayAgainSessionWithTopic:(QZBGameTopic *)topic user:(id <QZBUserProtocol>)user {
  self.isPlayAgain = YES;

  [self initSessionWithTopic:topic user:user];//initPlayAgainSessionWithTopic:topic user:user];
}

#pragma mark - Actions

- (IBAction)cancelCrossAction:(id)sender {
  [self closeFinding];

  [[QZBServerManager sharedManager] PATCHCloseLobby:self.lobby
                                          onSuccess:^(QZBSession *session, id bot) {
                                          }
                                          onFailure:^(NSError *error, NSInteger statusCode) {
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

    if (!self.alertShown) {
      self.alertShown = YES;
      [[[UIAlertView alloc] initWithTitle:description[0]
                                  message:description[1]
                                 delegate:self
                        cancelButtonTitle:@"Ок"
                        otherButtonTitles:nil] show];
    }
  }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex; {
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
                                                            onFailure:^(NSError *error, NSInteger statusCode) {
                                                              [self showAlertServerProblem];
                                                            }];
  } else if (!self.user) {
    [[QZBServerManager sharedManager] POSTLobbyWithTopic:self.topic
                                               onSuccess:^(QZBLobby *lobby) {

                                                 [self sessionFromLobby:lobby];
                                               }
                                               onFailure:^(NSError *error, NSInteger statusCode) {
                                                 [self showAlertServerProblem];
                                               }];
  } else if (!self.isChallenge) {
    if (self.isPlayAgain) {

      [[QZBServerManager sharedManager] GETThrownChallengesOnSuccess:^(NSArray *challenges) {

        QZBChallengeDescription *destChallDescr = nil;
        for (QZBChallengeDescription *CD in challenges) {

          NSLog(@"self %@ CD %@", self.topic.topic_id, CD.topicID);
          if ([CD.userID isEqual:self.user.userID] &&
              [CD.topicID isEqual:self.topic.topic_id]) {
            destChallDescr = CD;
            break;
          }
        }
        if (destChallDescr) {
          [self acceptChallengeWithLobbyNumber:destChallDescr.lobbyID];
        } else {
          [self postLobbyChallenge];
        }
      }                                                    onFailure:^(NSError *error, NSInteger statusCode) {
        [self showAlertServerProblem];
      }];
    } else {
      [self postLobbyChallenge];
    }
  } else {
  }
}

- (void)acceptChallengeWithLobbyNumber:(NSNumber *)lobbyID {
  [[QZBServerManager sharedManager] POSTAcceptChallengeWhithLobbyID:lobbyID
                                                          onSuccess:^(QZBSession *session, QZBOpponentBot *bot) {

                                                            [self settitingSession:session bot:bot];
                                                          }
                                                          onFailure:^(NSError *error, NSInteger statusCode) {
                                                            [self showAlertServerProblem];
                                                          }];
}

- (void)postLobbyChallenge {
  [[QZBServerManager sharedManager] POSTLobbyChallengeWithUserID:self.user.userID
                                                         inTopic:self.topic
                                                       onSuccess:^(QZBSession *session) {

                                                         [self setFactWithString:session.fact];

                                                         QZBLobby *lobby = [[QZBLobby alloc] initWithLobbyID:[session.lobbyID integerValue]
                                                                                                     topicID:[self.topic.topic_id integerValue]
                                                                                                    playerID:[self.user.userID integerValue]
                                                                                                  queryCount:0];
                                                         self.lobby = lobby;

                                                         [self settitingSession:session bot:nil];

                                                         [UIView animateWithDuration:0.4
                                                                               delay:5
                                                                             options:UIViewAnimationOptionCurveEaseInOut
                                                                          animations:^{

                                                                            self.playOfflineButton.alpha = 1.0;
                                                                          }
                                                                          completion:^(BOOL finished) {

                                                                            self.playOfflineButton.enabled = YES;
                                                                          }];
                                                       }
                                                       onFailure:^(NSError *error, NSInteger statusCode) {

                                                         [self showAlertServerProblem];
                                                         //  }
                                                       }];
}

- (void)showAlertServerProblem {
  [[[UIAlertView alloc] initWithTitle:@"Ошибка на сервере"
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
  DDLogInfo(@"%ld", (unsigned long) _counter);

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
      if (self.isChallenge || self.user) {
        [[QZBSessionManager sessionManager] setIsChallenge:YES];
      }

      if ([bot isKindOfClass:[QZBOpponentBot class]]) {
        [[QZBSessionManager sessionManager] setBot:(QZBOpponentBot *) bot];
        if (!self.isEntered) {
          self.isEntered = YES;
          [self.onlineWorker closeConnection];
          self.onlineWorker = nil;
          [self performSegueWithIdentifier:@"showGame" sender:nil];
        }
      } else {
        self.isOnline = YES;
        [[QZBSessionManager sessionManager]
            setOnlineSessionWorkerFromOutside:self.onlineWorker];

        if (!self.user && self.isChallenge) {
          dispatch_after(
              dispatch_time(DISPATCH_TIME_NOW, (int64_t) (6 * NSEC_PER_SEC)),
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
  } else {
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

- (void)initWhiteViewOn:(UIView *)view {
  CGRect r = [UIScreen mainScreen].bounds;

  UIView *vi = [[UIView alloc] initWithFrame:r];
  vi.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
  [view addSubview:vi];
  [view sendSubviewToBack:vi];
}

- (void)addSpinner {
  self.animationView =
      [[SVIndefiniteAnimatedView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];

  self.animationView.strokeThickness = 2.0;
  self.animationView.strokeColor = [UIColor redColor];
  self.animationView.radius = 48.0;

  [self.backView addSubview:self.animationView];

  self.animationView.translatesAutoresizingMaskIntoConstraints = NO;

  UIView *redView = self.animationView;

  [self.backView
      addConstraints:[NSLayoutConstraint
          constraintsWithVisualFormat:@"H:|-(>=0)-[redView(==100)]-(>=0)-|"
                              options:0
                              metrics:nil
                                views:NSDictionaryOfVariableBindings(redView)]];
  [self.backView
      addConstraints:[NSLayoutConstraint
          constraintsWithVisualFormat:@"V:|-(>=0)-[redView(==100)]-(>=0)-|"
                              options:0
                              metrics:nil
                                views:NSDictionaryOfVariableBindings(redView)]];
}

#pragma mark - support method

- (void)setFactWithString:(NSString *)fact {
  self.factLabel.text = fact;

  [UIView animateWithDuration:0.4
                   animations:^{
                     self.factLabel.superview.alpha = 1.0;
                   }];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

@end
