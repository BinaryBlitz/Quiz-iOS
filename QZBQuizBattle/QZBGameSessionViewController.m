//
//  ViewController.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 11/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import "QZBGameSessionViewController.h"
#import "QZBSession.h"
#import "QZBSessionManager.h"
#import "QZBAnswerButton.h"
#import "QZBTopicChooserControllerViewController.h"
#import "UIColor+QZBProjectColors.h"
#import <JSBadgeView/JSBadgeView.h>
#import <UAProgressView.h>
#import "UIImageView+AFNetworking.h"
#import "QZBCategory.h"
#import "UIView+QZBShakeExtension.h"

static float QZB_TIME_OF_COLORING_SCORE_LABEL = 1.5;
static float QZB_TIME_OF_COLORING_BUTTONS = 0.5;

@interface QZBGameSessionViewController ()<UIAlertViewDelegate>

@property (assign, nonatomic) int time;

@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (strong, nonatomic) NSTimer *globalTimer;  //нужен для работы проги в бекграунде
//@property (strong, nonatomic) UAProgressView *progressView;

@property(strong, nonatomic) JSBadgeView *userBV;
@property(strong, nonatomic) JSBadgeView *opponentBV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalConstraint;
@property(assign, nonatomic) BOOL isEnded;


@end

@implementation QZBGameSessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];

    //[[self navigationController] setNavigationBarHidden:YES animated:NO];
    self.backgroundTask = UIBackgroundTaskInvalid;

    for (UIButton *b in self.answerButtons) {
        b.enabled = NO;
        b.alpha = 0.0;
        [b setExclusiveTouch:YES];
        b.titleLabel.minimumScaleFactor = 0.5;
        b.titleLabel.adjustsFontSizeToFitWidth = YES;
        b.titleLabel.numberOfLines = 0;
        CGFloat inset = CGRectGetHeight(b.frame)/5;
        b.titleEdgeInsets = UIEdgeInsetsMake(inset/3, inset/3, inset/3, inset/3);
        
        //b.titleLabel.lineBreakMode = NSLineBreakByClipping;
    
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
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    
 //   self.firstUserScore.hidden = YES;
   // self.opponentScore.hidden = YES;
    
   // self.originalPosition = self.questionImageView.frame;
    
    self.firstUserScore.text = @"";
    self.opponentScore.text = @"";
  
    [self.roundLabel addShadows];
    
    self.userBV= [[JSBadgeView alloc] initWithParentView:self.firstUserScore
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
    self.roundLabel.adjustsFontSizeToFitWidth = YES;
    
    QZBGameTopic *topic = [QZBSessionManager sessionManager].topic;
    
    QZBCategory *category = [[QZBServerManager sharedManager] tryFindRelatedCategoryToTopic:topic];
    if(category){
        
        NSURL *url = [NSURL URLWithString:category.background_url];
        NSURLRequest *imageRequest =
        [NSURLRequest requestWithURL:url
                         cachePolicy:NSURLRequestReturnCacheDataElseLoad
                     timeoutInterval:60];
        //   UIImage *image = [[UIImage alloc] init];
        
        [self.backgroundImageView setImageWithURLRequest:imageRequest
                                        placeholderImage:nil
                                                 success:nil
                                                 failure:nil];
        

        
    }
    
   
    
    
}

-(void)initCircularProgress{
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
    [self prepareQuestion];
    [self showQuestionAndAnswers];
    [self timeCountingStart];

    self.backgroundTask =
        [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            NSLog(@"Background handler called. Not running background tasks anymore.");
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
            self.backgroundTask = UIBackgroundTaskInvalid;
        }];
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

    // NSLog(@"%d",self.time);
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
    // NSLog(@"%ld", (long)sender.tag);

    for (UIButton *b in self.answerButtons) {
        b.enabled = NO;
    }

    [[QZBSessionManager sessionManager] firstUserAnswerCurrentQuestinWithAnswerNumber:sender.tag];

    [self setScores];
    [self colorFirstUserScoreLabel];

    NSUInteger num = [QZBSessionManager sessionManager].firstUserLastAnswer.answer.answerNum;
    BOOL isTrue = [QZBSessionManager sessionManager].firstUserLastAnswer.isRight;

    NSLog(@"Answer %ld %d", (unsigned long)num, isTrue);

    QZBAnswerButton *button = (QZBAnswerButton *)sender;

    //[button addTriangleLeft];
    [button addCircleLeft];

    UIColor *color;

    if (isTrue) {
        color = [UIColor transperentLightGreenColor];
    } else {
        color = [UIColor transperentLightRedColor];
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        

    [UIView animateWithDuration:QZB_TIME_OF_COLORING_BUTTONS
        animations:^{
            sender.backgroundColor = color;
        }
        completion:^(BOOL finished){

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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        
        [self.globalTimer invalidate];
        self.globalTimer = nil;
        
        if (self.backgroundTask != UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
            self.backgroundTask = UIBackgroundTaskInvalid;
        }
        
        [[QZBSessionManager sessionManager] closeSession];
        
        //[self.navigationController popViewControllerAnimated:YES];
        
        UIViewController *destinationVC = nil;
        
        for (UIViewController *vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:[QZBTopicChooserControllerViewController class]]) {
                destinationVC = vc;
                break;
            }
        }
        
        self.isEnded = YES;//чтобы не открылся последний экран если пользователь сдался
        
        if (destinationVC) {
            [self.navigationController popToViewController:destinationVC animated:YES];
        }else {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

#pragma mark - init qestion

- (void)prepareQuestion {
    QZBQuestion *question = [QZBSessionManager sessionManager].currentQuestion;

    self.qestionLabel.text = question.question;
    

    self.questionImageView.image = nil;
    if(question.imageURL){
        //self.questionImageView.frame = self.originalPosition;
        [self.questionImageView setImageWithURL:question.imageURL];
        self.verticalConstraint.constant = 30;
        [self.qestionLabel layoutIfNeeded];
    }else{
    
        self.verticalConstraint.constant = self.questBackground.frame.size.height-20.0;
      //  self.verticalConstraint.constant = 10;
        [self.qestionLabel layoutIfNeeded];
    
        
        
//        self.questionImageView.constraint
//        
//        [self.qestionLabel layoutIfNeeded];
//        [self.questionImageView layoutIfNeeded];
      //  CGRect r = self.questionImageView.superview.frame;
        
       // self.questionImageView.frame = CGRectMake(50, 0, 100, 1);
      //  [self updateViewConstraints];
    }
    
    int i = 0;
    for (UIButton *b in self.answerButtons) {
        QZBAnswerTextAndID *answerAndId = question.answers[i];

        [b setTitle:answerAndId.answerText forState:UIControlStateNormal];
        b.tag = answerAndId.answerID;
        i++;
    }
}


//показывает лейбл раунда
- (void)showQuestionAndAnswers {
    [self prepareQuestion];
    __weak typeof(self) weakSelf = self;

    NSUInteger roundNum = [QZBSessionManager sessionManager].roundNumber;

    NSString *roundAsString = [NSString stringWithFormat:@"Раунд %ld", (unsigned long)roundNum];
    
    self.roundLabel.text = roundAsString;
    self.title = roundAsString;
    
    NSLog(@"Before showing label");

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

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       for (UIButton *button in weakSelf.answerButtons) {
                           button.backgroundColor = [UIColor transperentBlackColor];
                           button.enabled = YES;
                           [UIView animateWithDuration:0.3
                               animations:^{
                                   button.alpha = 1.0;
                               }
                               completion:^(BOOL finished) {
                                   button.enabled = YES;

                               }];
                       }
                       [UIView animateWithDuration:0.3
                           animations:^{
                               weakSelf.timeLabel.alpha = 1.0;
                               weakSelf.progressView.alpha = 1.0;
                           }
                           completion:^(BOOL finished){
                              
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
        
        
        
    } completion:^(BOOL finished) {
        
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
                QZBAnswerButton *b = (QZBAnswerButton *)button;
                //[b unshowTriangles];
                [b unshowCircles];
                NSLog(@"Buttons and over unshow");
            }];
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"currentTime"]) {
        
        [self.progressView setProgress:([[change objectForKey:@"new"] integerValue])/100.0
                              animated:YES];

        self.timeLabel.text = [NSString stringWithFormat:@"%ld", 10 -
                               [[change objectForKey:@"new"] integerValue]/10 ];
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

    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{

                       [self UNShowQuestinAndAnswers];
                       //[self prepareQuestion];
                       NSLog(@"before before showing");
                       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
                                      dispatch_get_main_queue(), ^{
                                          [weakSelf showQuestionAndAnswers];
                                         
                                      });
                   });
}

- (void)showResultOfQuestion {
    QZBQuestionWithUserAnswer *qanda = [QZBSessionManager sessionManager].opponentUserLastAnswer;

    QZBQuestion *quest = [[QZBSessionManager sessionManager].askedQuestions lastObject];

    NSLog(@"%ld", (unsigned long)quest.rightAnswer);

    for (QZBAnswerButton *b in self.answerButtons) {
        b.enabled = NO;
        if (b.tag == quest.rightAnswer) {
            [UIView animateWithDuration:QZB_TIME_OF_COLORING_BUTTONS
                animations:^{
                    b.backgroundColor = [UIColor transperentLightGreenColor];
                }
                completion:^(BOOL finished){

                }];
        } else {
            [UIView animateWithDuration:QZB_TIME_OF_COLORING_BUTTONS
                delay:1.0
                options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionNone
                animations:^{
                    b.alpha = 0;
                }
                completion:^(BOOL finished){

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
                            b.backgroundColor = [UIColor transperentLightRedColor];//??
                        }
                        completion:^(BOOL finished){

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

        __weak typeof(self) weakSelf = self;
        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)),
            dispatch_get_main_queue(), ^{
                
                if(!self.isEnded){
                
                [self setScores];

                [self UNShowQuestinAndAnswers];

                NSLog(@"session ended");

                    if(![QZBSessionManager sessionManager].isOfflineChallenge){
                        self.roundLabel.text = (NSString *)notification.object;
                    }else{
                        self.roundLabel.text = @"Ждем соперника";
                    }

                [UIView animateWithDuration:0.3
                    delay:0.5
                    options:UIViewAnimationOptionCurveEaseInOut |
                            UIViewAnimationOptionTransitionNone
                    animations:^{
                        weakSelf.roundLabel.alpha = 1.0;
                    }
                    completion:^(BOOL finished) {

                        [self.globalTimer invalidate];
                        self.globalTimer = nil;

                        if (self.backgroundTask != UIBackgroundTaskInvalid) {
                            [[UIApplication sharedApplication]
                                endBackgroundTask:self.backgroundTask];
                            self.backgroundTask = UIBackgroundTaskInvalid;
                        }

                        dispatch_after(
                            dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),
                            dispatch_get_main_queue(), ^{

                                [weakSelf performSegueWithIdentifier:@"gameEnded" sender:nil];

                            });

                    }];

                }});
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
stringWithFormat:@"%ld", (unsigned long)[QZBSessionManager sessionManager].firstUserScore];
    
    NSString *opponentScoreString = [NSString
                                     stringWithFormat:@"%ld", (unsigned long)[QZBSessionManager sessionManager].secondUserScore];
    
   
    
    self.userBV.badgeText = firstScoreString;
    self.opponentBV.badgeText = opponentScoreString;
    
   // self.firstUserScore.text = firstScoreString;
   // self.opponentScore.text = opponentScoreString;
}

#pragma mark - score labels colored

- (void)colorOpponentUserScoreLabel {
    
    if([QZBSessionManager sessionManager].isOfflineChallenge){
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
        completion:^(BOOL finished){

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
        completion:^(BOOL finished){

        }];
}


#pragma mark - user interface

- (void)setNamesAndUserpics {
    self.userNameLabel.text = [QZBSessionManager sessionManager].firstUserName;

    if ([QZBSessionManager sessionManager].opponentUserName) {
        self.opponentNameLabel.text = [QZBSessionManager sessionManager].opponentUserName;
    }
    
    if([QZBSessionManager sessionManager].firstImageURL){
        [self.userImage setImageWithURL:[QZBSessionManager sessionManager].firstImageURL];
    }else{
        
        [self.userImage setImage:[UIImage imageNamed:@"userpicStandart"]];
        
    }
    
    if([QZBSessionManager sessionManager].opponentImageURL){
        [self.opponentImage setImageWithURL:[QZBSessionManager sessionManager].opponentImageURL];
    }else{
        
        [self.opponentImage setImage:[UIImage imageNamed:@"userpicStandart"]];
        
    }
    
}


#pragma mark - status bar

- (BOOL)prefersStatusBarHidden {
    return NO;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


@end
