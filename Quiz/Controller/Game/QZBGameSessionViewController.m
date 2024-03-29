#import "QZBGameSessionViewController.h"
#import "QZBSession.h"
#import "QZBSessionManager.h"
#import "QZBAnswerButton.h"
#import "QZBTopicChooserController.h"
#import "UIColor+QZBProjectColors.h"
#import <JSBadgeView/JSBadgeView.h>
#import "UIImageView+AFNetworking.h"
#import "QZBCategory.h"
#import "UIView+QZBShakeExtension.h"
#import <JSQSystemSoundPlayer.h>

#import "QZBCurrentUser.h"
#import "QZBTopicWorker.h"
#import "QZBGameTopic.h"

#import <DFImageManager/DFImageManager.h>
#import <DFImageManager/DFImageRequestOptions.h>
#import <DFImageManager/DFURLImageFetcher.h>
#import <DFImageManager/DFImageRequest.h>
#import <DFImageManager/DFImageView.h>

// Rooms
#import "QZBRoomWorker.h"
#import "QZBRoom.h"
#import "QZBUserWithTopic.h"
#import "QZBRoomUsersView.h"

@import AVFoundation;

static float QZB_TIME_OF_COLORING_SCORE_LABEL = 1.5;
static float QZB_TIME_OF_COLORING_BUTTONS = 0.5;

NSString *const QZBRoomResultSegueIdentifier = @"showRoomResults";

@interface QZBGameSessionViewController () <UIAlertViewDelegate>

@property (assign, nonatomic) int time;

@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (strong, nonatomic) NSTimer *globalTimer;  //нужен для работы проги в бекграунде
//@property (strong, nonatomic) UAProgressView *progressView;

@property (strong, nonatomic) JSBadgeView *userBV;
@property (strong, nonatomic) JSBadgeView *opponentBV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalConstraint;
@property (assign, nonatomic) BOOL isEnded;

@property (strong, nonatomic) QZBRoomUsersView *roomUsersView;

@property (strong, nonatomic) AVAudioPlayer *soundPlayer;

@end

@implementation QZBGameSessionViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  [self setNeedsStatusBarAppearanceUpdate];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"QZBDoNotNeedShowMessagerNotifications" object:nil];

  [[JSQSystemSoundPlayer sharedPlayer] preloadSoundWithFilename:@"timer"
                                                  fileExtension:kJSQSystemSoundTypeWAV];
  self.backgroundTask = UIBackgroundTaskInvalid;

  for (UIButton *b in self.answerButtons) {
    b.enabled = NO;
    b.alpha = 0.0;
    [b setExclusiveTouch:YES];
    b.titleLabel.minimumScaleFactor = 0.5;
    b.titleLabel.adjustsFontSizeToFitWidth = YES;
    b.titleLabel.lineBreakMode = NSLineBreakByClipping;
    b.titleLabel.numberOfLines = 0;
    CGFloat inset = CGRectGetHeight(b.frame) / 5;
    b.titleEdgeInsets = UIEdgeInsetsMake(inset / 3, inset / 3, inset / 3, inset / 3);
    [b setTitle:@"" forState:UIControlStateNormal];
  }

  [[QZBSessionManager sessionManager] addObserver:self
                                       forKeyPath:@"currentTime"
                                          options:NSKeyValueObservingOptionNew
                                          context:nil];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(unshowQuestionNotification:)
                                               name:@"QZBNeedUnshowQuestion"
                                             object:nil];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(endGameSession:)
                                               name:@"QZBNeedFinishSession"
                                             object:nil];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(opponentMadeChoose:)
                                               name:@"QZBOpponentUserMadeChoose"
                                             object:nil];

  if ([QZBSessionManager sessionManager].roomWorker) {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setRoomUsersScores:)
                                                 name:QZBOneOfUserInRoomGaveAnswer
                                               object:nil];
  }
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [[self navigationController] setNavigationBarHidden:NO animated:NO];

  self.firstUserScore.text = @"";
  self.opponentScore.text = @"";

  if ([QZBSessionManager sessionManager].isRoom) {

    self.userNameLabel.superview.backgroundColor = [UIColor colorWithWhite:0.8
                                                                     alpha:0.5];
  }

  self.userBV = [[JSBadgeView alloc] initWithParentView:self.firstUserScore
                                              alignment:JSBadgeViewAlignmentCenterLeft];
  self.opponentBV = [[JSBadgeView alloc] initWithParentView:self.opponentScore
                                                  alignment:JSBadgeViewAlignmentCenterRight];

  self.userBV.badgeTextFont = [UIFont systemFontOfSize:20];
  self.opponentBV.badgeTextFont = [UIFont systemFontOfSize:20];
  self.userBV.badgeBackgroundColor = [UIColor transperentLightBlueColor];
  self.opponentBV.badgeBackgroundColor = [UIColor transperentLightBlueColor];

  self.opponentBV.badgeText = @"0";
  self.userBV.badgeText = @"0";

  [self initCircularProgress];
  [self setNamesAndUserpics];

  QZBGameTopic *topic = [QZBSessionManager sessionManager].topic;

  QZBCategory *category = [QZBTopicWorker tryFindRelatedCategoryToTopic:topic];
  if (category) {
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

  if ([QZBSessionManager sessionManager].roomWorker) {
    self.opponentImage.hidden = YES;
    self.opponentBV.hidden = YES;
    self.opponentNameLabel.hidden = YES;
  }
}

- (void)initCircularProgress {
  self.progressView.borderWidth = 0.0;
  self.progressView.lineWidth = 3.0;
  self.progressView.progress = 0;
  self.progressView.backgroundColor = [UIColor clearColor];
  self.progressView.centralView = self.timeLabel;
  self.progressView.fillOnTouch = NO;
  self.progressView.animationDuration = 0.1;
  self.progressView.tintColor = [UIColor brightRedColor];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  //[self prepareQuestion];
  [self showQuestionAndAnswers];
  [self timeCountingStart];

  self.tabBarController.tabBar.hidden = YES;

  self.backgroundTask =
      [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
      }];

  [self playGameSound];

  if ([QZBSessionManager sessionManager].roomWorker) {
    [self loadRoomView];
    [self setRoomsUsersScoresForUserWithID:@(-1) isCorrect:NO];
  }
}

- (void)playGameSound {
  //    [[JSQSystemSoundPlayer sharedPlayer] playSoundWithFilename:@"melodyshort" fileExtension:kJSQSystemSoundTypeWAV completion:^{
  //        [weakSelf playGameSound];
  //    }];

  if ([JSQSystemSoundPlayer sharedPlayer].on) {

    NSString *soundFilePath = [NSString stringWithFormat:@"%@/melody.wav",
                                                         [[NSBundle mainBundle] resourcePath]];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    NSError *error;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL
                                                                   error:&error];

    self.soundPlayer = player;

    player.numberOfLoops = -1; //Infinite
    [player prepareToPlay];
    [player play];
  }
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [[JSQSystemSoundPlayer sharedPlayer] stopAllSounds];

  if (self.soundPlayer) {
    [self.soundPlayer stop];
  }
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"QZBNeedShowMessagerNotifications" object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self];//TEST
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];

  @try {
    [[QZBSessionManager sessionManager] removeObserver:self forKeyPath:@"currentTime"];
  }
  @catch (NSException *__unused exception) {
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - test methods

- (void)timeCountingStart {
  self.time = 0;
  self.globalTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(updateTime:)
                                                    userInfo:nil
                                                     repeats:YES];
}

- (void)updateTime:(NSTimer *)timer {
  self.time++;

  if (self.time < 1000) {
  } else {
    if (timer != nil) {
      self.time = 0;
      [timer invalidate];
      timer = nil;

      if (self.backgroundTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
      }
    }
  }
}

#pragma mark - actions

- (IBAction)pressAnswerButton:(UIButton *)sender {
  for (UIButton *b in self.answerButtons) {
    b.enabled = NO;
  }

  [[QZBSessionManager sessionManager] firstUserAnswerCurrentQuestinWithAnswerNumber:sender.tag];

  [self setScores];
  [self colorFirstUserScoreLabel];

  BOOL isTrue = [QZBSessionManager sessionManager].firstUserLastAnswer.isRight;

  QZBAnswerButton *button = (QZBAnswerButton *) sender;

  [button addCircleLeft];

  UIColor *color;

  if (isTrue) {
    color = [UIColor transperentLightGreenColor];
  } else {
    color = [UIColor transperentLightRedColor];
  }

  [[JSQSystemSoundPlayer sharedPlayer] stopSoundWithFilename:@"timer"];
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.3 * NSEC_PER_SEC)),
      dispatch_get_main_queue(), ^{
        if (!isTrue) {
          [[JSQSystemSoundPlayer sharedPlayer]         playSoundWithFilename:@"wrong"
                                                       fileExtension:kJSQSystemSoundTypeWAV];
          [[JSQSystemSoundPlayer sharedPlayer] playVibrateSound];
        } else {
          [[JSQSystemSoundPlayer sharedPlayer]         playSoundWithFilename:@"correct"
                                                       fileExtension:kJSQSystemSoundTypeWAV];
        }

        [UIView          animateWithDuration:QZB_TIME_OF_COLORING_BUTTONS
                         animations:^{
                           sender.backgroundColor = color;
                         }
                         completion:^(BOOL finished) {
                         }];
      });
}

- (IBAction)closeSession:(id)sender {
  [[[UIAlertView alloc] initWithTitle:@"Сдаться?"
                              message:@"Вы уверены?"
                             delegate:self
                    cancelButtonTitle:@"Отмена"
                    otherButtonTitles:@"Ок", nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 1) {
    [self.globalTimer invalidate];
    self.globalTimer = nil;

    if (self.backgroundTask != UIBackgroundTaskInvalid) {
      [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
      self.backgroundTask = UIBackgroundTaskInvalid;
    }

    [[QZBSessionManager sessionManager] closeSession];

    UIViewController *destinationVC = nil;

    for (UIViewController *vc in self.navigationController.viewControllers) {
      if ([vc isKindOfClass:[QZBTopicChooserController class]]) {
        destinationVC = vc;
        break;
      }
    }

    self.isEnded = YES;  //чтобы не открылся последний экран если пользователь сдался

    if (destinationVC) {
      [self.navigationController popToViewController:destinationVC animated:YES];
    } else {
      [self.navigationController popToRootViewControllerAnimated:YES];
    }
  }
}

#pragma mark - init qestion

- (void)prepareQuestion {
  QZBQuestion *question = [QZBSessionManager sessionManager].currentQuestion;

  self.qestionLabel.text = question.question;

  self.questionImageView.image = nil;
  if (question.imageURL) {

    DFMutableImageRequestOptions *options = [DFMutableImageRequestOptions new];

    options.allowsClipping = YES;
    options.userInfo = @{DFURLRequestCachePolicyKey: @(NSURLRequestReturnCacheDataElseLoad)};
    options.priority = DFImageRequestPriorityHigh;

    DFImageRequest *request = [DFImageRequest requestWithResource:question.imageURL targetSize:CGSizeZero contentMode:DFImageContentModeAspectFill options:options];

    self.questionImageView.allowsAnimations = YES;

    [self.questionImageView prepareForReuse];
    [self.questionImageView setImageWithRequest:request];

    self.verticalConstraint.constant = [self calculateVerticalConstraints];
    [self.qestionLabel layoutIfNeeded];
  } else {
    self.verticalConstraint.constant = self.questBackground.frame.size.height - 20.0;
    [self.qestionLabel layoutIfNeeded];
  }

  int i = 0;
  for (QZBAnswerButton *b in self.answerButtons) {
    QZBAnswerTextAndID *answerAndId = question.answers[i];

    [b setAnswerText:answerAndId.answerText];

    b.tag = answerAndId.answerID;
    i++;
  }
}

- (CGFloat)calculateVerticalConstraints {
  CGFloat width = CGRectGetWidth(self.questBackground.frame) - 16.0;
  CGFloat heigth = CGRectGetHeight(self.questBackground.frame) - 24.0;

  if ((heigth - (width * 9.0) / 16.0) < 30) {
    return 30.0;
  } else {
    return heigth - (width * 9.0) / 16.0;
  }
}

// Round label
- (void)showQuestionAndAnswers {
  [self prepareQuestion];
  __weak typeof(self) weakSelf = self;

  NSUInteger roundNum = [QZBSessionManager sessionManager].roundNumber;

  NSString *roundAsString = [NSString stringWithFormat:@"Раунд %ld", (unsigned long) roundNum];
  self.title = roundAsString;
  if ([QZBSessionManager sessionManager].isDoubled) {
    roundAsString = [roundAsString stringByAppendingString:@"\nОчки X2"];
  }
  QZBGameTopic *topic = [QZBSessionManager sessionManager].currentQuestion.topic;
  if (topic && [QZBSessionManager sessionManager].isRoom) {
    NSString *stringToAppend = [NSString stringWithFormat:@"\n%@", topic.name];
    roundAsString = [roundAsString stringByAppendingString:stringToAppend];
  }
  self.roundLabel.text = roundAsString;

  [UIView animateWithDuration:0.3
                        delay:0
                      options:UIViewAnimationOptionTransitionNone
                   animations:^{
                     weakSelf.roundLabel.alpha = 1.0;
                   }
                   completion:^(BOOL finished) {
                     [UIView animateWithDuration:0.1
                                           delay:1
                                         options:UIViewAnimationOptionTransitionNone
                                      animations:^{
                                        weakSelf.roundLabel.alpha = 0.0;
                                      }
                                      completion:^(BOOL finished) {
                                        [weakSelf showOnlyQuestionAndAnswers];
                                      }];
                   }];
}

//вызывается после показа лейбла с номером раунда
- (void)showOnlyQuestionAndAnswers {
  __weak typeof(self) weakSelf = self;

  [UIView animateWithDuration:0.2
                   animations:^{
                     self.questBackground.alpha = 1.0;
                     self.qestionLabel.alpha = 1.0;
                   }];
  //REDO TIME
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (3 * NSEC_PER_SEC)),
      dispatch_get_main_queue(), ^{
        for (UIButton *button in weakSelf.answerButtons) {
          button.backgroundColor = [UIColor transperentBlackColor];
          button.enabled = YES;
          [UIView          animateWithDuration:0.3
                           animations:^{
                             button.alpha = 1.0;
                           }
                           completion:^(BOOL finished) {
                             button.enabled = YES;
                           }];
        }
        [UIView          animateWithDuration:0.3
                         animations:^{
                           weakSelf.timeLabel.alpha = 1.0;
                           weakSelf.progressView.alpha = 1.0;
                         }
                         completion:^(BOOL finished) {

                           //[[QZBSessionManager sessionManager] newQuestionStart];
                         }];

        [[QZBSessionManager sessionManager] newQuestionStart];
      });
}

- (void)UNShowQuestinAndAnswers {
  [self setScores];

  static float unShowTime = 0.5;

  __weak typeof(self) weakSelf = self;

  [UIView animateWithDuration:unShowTime
                   animations:^{

                     weakSelf.qestionLabel.alpha = .0;
                     weakSelf.questBackground.alpha = .0;
                     weakSelf.opponentScore.textColor = [UIColor whiteColor];
                     weakSelf.firstUserScore.textColor = [UIColor whiteColor];
                     weakSelf.userBV.badgeBackgroundColor = [UIColor transperentLightBlueColor];
                     weakSelf.opponentBV.badgeBackgroundColor = [UIColor transperentLightBlueColor];

                     weakSelf.timeLabel.alpha = .0;
                     weakSelf.progressView.alpha = .0;
                   }
                   completion:^(BOOL finished) {

                     weakSelf.progressView.progress = 0.0;
                   }];

  for (UIButton *button in weakSelf.answerButtons) {
    button.enabled = NO;
    [UIView animateWithDuration:unShowTime
                     animations:^{
                       button.alpha = .0;
                     }
                     completion:^(BOOL finished) {
                       button.enabled = YES;
                       QZBAnswerButton *b = (QZBAnswerButton *) button;
                       //[b unshowTriangles];
                       [b unshowCircles];
                     }];
  }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  if ([keyPath isEqualToString:@"currentTime"]) {

    NSInteger num = [[change objectForKey:@"new"] integerValue];

    [self.progressView setProgress:num / 100.0
                          animated:YES];

    self.timeLabel.text = [NSString
        stringWithFormat:@"%ld", (long) (10 - num / 10)];

    //int num = [[change objectForKey:@"new"] integerValue] ;
    //   NSLog(@"%d", num);
    if (num == 50 &&
        ![QZBSessionManager sessionManager].didFirstUserAnswered) {

      [[JSQSystemSoundPlayer sharedPlayer] playSoundWithFilename:@"timer"
                                                   fileExtension:kJSQSystemSoundTypeWAV];
    }
  }
}

#pragma mark - recievers

//принимает нотификейшен о необходимости закрыть вопрос из QZBSessionManager
- (void)unshowQuestionNotification:(NSNotification *)notification {
  if ([[notification name] isEqualToString:@"QZBNeedUnshowQuestion"]) {
    [self unshowQuestion];
  }
}

- (void)unshowQuestion {
  [self setScores];
  [self showResultOfQuestion];
  [[JSQSystemSoundPlayer sharedPlayer] stopSoundWithFilename:@"timer"];

  __weak typeof(self) weakSelf = self;
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (2.0 * NSEC_PER_SEC)),
      dispatch_get_main_queue(), ^{

        [self UNShowQuestinAndAnswers];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1 * NSEC_PER_SEC)),
            dispatch_get_main_queue(), ^{
              [weakSelf showQuestionAndAnswers];
            });
      });
}

- (void)showResultOfQuestion {
  QZBQuestionWithUserAnswer *qanda = [QZBSessionManager sessionManager].opponentUserLastAnswer;

  QZBQuestion *quest = [[QZBSessionManager sessionManager].askedQuestions lastObject];

  for (QZBAnswerButton *b in self.answerButtons) {
    b.enabled = NO;
    if (b.tag == quest.rightAnswer) {
      [UIView animateWithDuration:QZB_TIME_OF_COLORING_BUTTONS
                       animations:^{
                         b.backgroundColor = [UIColor transperentLightGreenColor];
                       }
                       completion:^(BOOL finished) {
                       }];
    } else {
      [UIView animateWithDuration:QZB_TIME_OF_COLORING_BUTTONS
                            delay:1.0
                          options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionNone
                       animations:^{
                         b.alpha = 0;
                       }
                       completion:^(BOOL finished) {
                       }];
    }

    if (qanda) {
      NSUInteger num = qanda.answer.answerNum;
      NSInteger right = qanda.question.rightAnswer;

      if (b.tag == num) {
        //[b addTriangleRight];
        [b addCircleRight];
        if (b.tag != right) {
          [UIView animateWithDuration:QZB_TIME_OF_COLORING_BUTTONS
                           animations:^{
                             b.backgroundColor = [UIColor transperentLightRedColor];
                           }
                           completion:^(BOOL finished) {
                           }];
        }
      }
    }
  }
}

//принимает нотификейшен о окончании сессии из QZBSessionManager
- (void)endGameSession:(NSNotification *)notification {
  if ([[notification name] isEqualToString:@"QZBNeedFinishSession"]) {
    self.navigationController.navigationItem.leftBarButtonItem.enabled = NO;

    [self setScores];

    [self showResultOfQuestion];

    //  __weak typeof(self) weakSelf = self;
    dispatch_after(
        dispatch_time(DISPATCH_TIME_NOW, (int64_t) (3 * NSEC_PER_SEC)),
        dispatch_get_main_queue(), ^{

          if (!self.isEnded) {
            [self setScores];
            [self UNShowQuestinAndAnswers];

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
              [self.globalTimer invalidate];
              self.globalTimer = nil;

              if (self.backgroundTask != UIBackgroundTaskInvalid) {
                [[UIApplication sharedApplication]
                    endBackgroundTask:self.backgroundTask];
                self.backgroundTask = UIBackgroundTaskInvalid;
              }
            });
            self.closeButton.enabled = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

              if ([QZBSessionManager sessionManager].isRoom) {

                [[QZBServerManager sharedManager]                                 POSTFinishRoomSessionWithID:[QZBSessionManager
                        sessionManager].roomWorker.room.roomID

                                                                    onSuccess:nil onFailure:nil];
                [self performSegueWithIdentifier:QZBRoomResultSegueIdentifier sender:nil];
              } else {
                [self performSegueWithIdentifier:@"gameEnded" sender:nil];
              }
            });
          }
        });
  }
}

//принимает нотификейшн о том что оппонент выбрал ответ
- (void)opponentMadeChoose:(NSNotification *)notification {
  if ([[notification name] isEqualToString:@"QZBOpponentUserMadeChoose"]) {
    [self setScores];
    [self colorOpponentUserScoreLabel];
  }
}

#pragma mark - game flow

- (void)setScores {
  NSString *firstScoreString = [NSString
      stringWithFormat:@"%ld", (unsigned long) [QZBSessionManager sessionManager].firstUserScore];

  NSString *opponentScoreString = [NSString
      stringWithFormat:@"%ld", (unsigned long) [QZBSessionManager sessionManager].secondUserScore];

  self.userBV.badgeText = firstScoreString;
  self.opponentBV.badgeText = opponentScoreString;
}

#pragma mark - score labels colored

- (void)colorOpponentUserScoreLabel {
  if ([QZBSessionManager sessionManager].isOfflineChallenge) {
    return;
  }

  __weak typeof(self) weakSelf = self;

  BOOL isRight = [QZBSessionManager sessionManager].opponentUserLastAnswer.isRight;

  UIColor *color;

  if (isRight) {
    color = [UIColor transperentLightGreenColor];
  } else {
    color = [UIColor transperentLightRedColor];
  }

  [UIView animateWithDuration:QZB_TIME_OF_COLORING_SCORE_LABEL
                   animations:^{

                     self.opponentBV.badgeBackgroundColor = color;
                     weakSelf.opponentScore.textColor = color;
                   }
                   completion:^(BOOL finished) {
                   }];
}

- (void)colorFirstUserScoreLabel {
  __weak typeof(self) weakSelf = self;

  BOOL isRight = [QZBSessionManager sessionManager].firstUserLastAnswer.isRight;

  UIColor *color;

  if (isRight) {
    color = [UIColor transperentLightGreenColor];
  } else {
    color = [UIColor transperentLightRedColor];
  }

  [UIView animateWithDuration:QZB_TIME_OF_COLORING_SCORE_LABEL
                   animations:^{
                     self.userBV.badgeBackgroundColor = color;
                     weakSelf.firstUserScore.textColor = color;
                   }
                   completion:^(BOOL finished) {
                   }];
}

#pragma mark - user interface

- (void)setNamesAndUserpics {
  self.userNameLabel.text = [QZBSessionManager sessionManager].firstUserName;

  if ([QZBSessionManager sessionManager].opponentUserName) {
    self.opponentNameLabel.text = [QZBSessionManager sessionManager].opponentUserName;
  }

  if ([QZBSessionManager sessionManager].firstImageURL) {
    [self.userImage setImageWithURL:[QZBSessionManager sessionManager].firstImageURL
                   placeholderImage:[UIImage imageNamed:@"userpicStandart"]];
  } else {
    [self.userImage setImage:[UIImage imageNamed:@"userpicStandart"]];
  }

  if ([QZBSessionManager sessionManager].opponentImageURL) {
    [self.opponentImage setImageWithURL:[QZBSessionManager sessionManager].opponentImageURL
                       placeholderImage:[UIImage imageNamed:@"userpicStandart"]];
  } else {
    [self.opponentImage setImage:[UIImage imageNamed:@"userpicStandart"]];
  }
}

#pragma mark - status bar

- (BOOL)prefersStatusBarHidden {
  return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

#pragma mark - room ui

- (void)loadRoomView {
  if ([QZBSessionManager sessionManager].roomWorker && !self.roomUsersView) {
    UIView *v = [[[NSBundle mainBundle] loadNibNamed:@"QZBRoomUsersView"
                                               owner:self
                                             options:nil] objectAtIndex:0];

    CGRect r = self.userImage.superview.frame;
    CGRect labelR = self.opponentNameLabel.frame;

    v.frame = CGRectMake(labelR.origin.x,
        0,
        labelR.size.width,
        r.size.height); // CGRectMake(0, 10, 100, 100);

    v.alpha = 0.0;
    [self.userImage.superview addSubview:v];
    self.roomUsersView = (QZBRoomUsersView *) v;
    v.backgroundColor = [UIColor clearColor];

    [UIView animateWithDuration:0.1
                     animations:^{
                       v.alpha = 1.0;
                     }];

    self.opponentImage.alpha = 0.0;
    self.opponentNameLabel.alpha = 0.0;
    self.opponentBV.alpha = 0.0;
  }
}

- (void)setRoomUsersScores:(NSNotification *)note {

  if ([note.name isEqualToString:QZBOneOfUserInRoomGaveAnswer]) {

    NSDictionary *payload = note.object;
    NSNumber *userID = payload[@"userID"];
    BOOL isCorrect = [payload[@"correct"] boolValue];

    [self setRoomsUsersScoresForUserWithID:userID isCorrect:isCorrect];
  }
}

- (void)setRoomsUsersScoresForUserWithID:(NSNumber *)userID isCorrect:(BOOL)correct {
  if ([QZBSessionManager sessionManager].roomWorker) {
    QZBRoom *room = [QZBSessionManager sessionManager].roomWorker.room;
    QZBUser *currentUser = [QZBCurrentUser sharedInstance].user;
    NSMutableArray *participatiens = [NSMutableArray array];

    for (QZBUserWithTopic *UWT in room.participants) {
      if (![UWT.user.userID isEqualToNumber:currentUser.userID]) {
        [participatiens addObject:UWT];
      }
    }

    for (int i = 0; i < self.roomUsersView.nameLabels.count; i++) {
      UILabel *nameLabel = self.roomUsersView.nameLabels[i];
      UILabel *scoreLabel = self.roomUsersView.usersScores[i];
      if (i < participatiens.count) {
        QZBUserWithTopic *userWithTopic = participatiens[i];

        nameLabel.text = userWithTopic.user.name;
        scoreLabel.text = userWithTopic.points.stringValue;
        id <QZBUserProtocol> user = userWithTopic.user;

        if ([userID isEqualToNumber:user.userID]) {
          UIColor *color = [UIColor lightGreenColor];
          if (!correct) {
            color = [UIColor lightRedColor];
          }
          [self colorLabel:nameLabel color:color];
          [self colorLabel:scoreLabel color:color];
        }
      } else {
        nameLabel.text = @"";
        scoreLabel.text = @"";
      }
    }
  }
}

- (void)colorLabel:(UILabel *)label color:(UIColor *)color {

  [UIView transitionWithView:label
                    duration:0.25
                     options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionCurveEaseInOut
                  animations:^{
                    label.textColor = color;
                  } completion:^(BOOL finished) {
      }];

  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

    [UIView transitionWithView:label
                      duration:0.1
                       options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                      label.textColor = [UIColor blackColor];
                    } completion:^(BOOL finished) {
        }];
  });
}

@end
