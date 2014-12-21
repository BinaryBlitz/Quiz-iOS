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

@interface QZBGameSessionViewController ()

@property(assign, nonatomic) int time;

@end

@implementation QZBGameSessionViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  for (UIButton *b in self.answerButtons) {
    b.enabled = NO;
    b.alpha = 0.0;
  }

  [[QZBSessionManager sessionManager] addObserver:self
                                       forKeyPath:@"currentTime"
                                          options:NSKeyValueObservingOptionNew
                                          context:nil];

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(unshowQuestionNotification:)
             name:@"QZBNeedUnshowQuestion"
           object:nil];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(endGameSession:)
                                               name:@"QZBNeedFinishSession"
                                             object:nil];

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(opponentMadeChoose:)
             name:@"QZBOpponentUserMadeChoose"
           object:nil];
  // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
  //[self prepareQestion:0];
  [self prepareQuestion];
  [self showQuestinAndAnswers];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [[QZBSessionManager sessionManager] removeObserver:self
                                          forKeyPath:@"currentTime"];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - actions

- (IBAction)pressAnswerButton:(UIButton *)sender {
  // NSLog(@"%ld", (long)sender.tag);
  [[QZBSessionManager sessionManager]
      firstUserAnswerCurrentQuestinWithAnswerNumber:sender.tag];

  [self setScores];

  NSUInteger num =
      [QZBSessionManager sessionManager].firstUserLastAnswer.answer.answerNum;
  BOOL isTrue = [QZBSessionManager sessionManager].firstUserLastAnswer.isRight;

  NSLog(@"Answer %ld %d", num, isTrue);

  QZBAnswerButton *button = (QZBAnswerButton *)sender;

  [button addTriangleLeft];

  if (isTrue) {
    sender.backgroundColor = [UIColor greenColor];
  } else {
    sender.backgroundColor = [UIColor redColor];
  }

  for (UIButton *b in self.answerButtons) {
    b.enabled = NO;
  }

  //[self UNShowQuestinAndAnswers];
}

#pragma mark - init qestion

- (void)prepareQuestion {
  QZBQuestion *question = [QZBSessionManager sessionManager].currentQuestion;

  self.qestionLabel.text = question.question;
  int i = 0;
  for (UIButton *b in self.answerButtons) {
    [b setTitle:question.answers[i] forState:UIControlStateNormal];
    i++;
  }
}

- (void)showQuestinAndAnswers {
  __weak typeof(self) weakSelf = self;

  NSUInteger roundNum = [QZBSessionManager sessionManager].roundNumber;

  self.roundLabel.text = [NSString stringWithFormat:@"Раунд %ld", roundNum];

  [UIView animateWithDuration:0.1
      delay:0
      options:UIViewAnimationOptionTransitionNone
      animations:^{ weakSelf.roundLabel.alpha = 1.0; }
      completion:^(BOOL finished) {
          [UIView animateWithDuration:0.2
              delay:1.2
              options:UIViewAnimationOptionTransitionNone
              animations:^{ weakSelf.roundLabel.alpha = 0.0; }
              completion:^(BOOL finished) {
                  [weakSelf showOnlyQuestionAndAnswers];

              }];
      }];

  //[[QZBSessionManager sessionManager] newQuestionStart];
}

- (void)showOnlyQuestionAndAnswers {
  __weak typeof(self) weakSelf = self;

  [UIView animateWithDuration:0.2
                   animations:^{ weakSelf.qestionLabel.alpha = 1.0; }];

  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
                 dispatch_get_main_queue(), ^{
      for (UIButton *button in weakSelf.answerButtons) {
        button.backgroundColor = [UIColor whiteColor];
        button.enabled = YES;
        [UIView animateWithDuration:0.3
            animations:^{ button.alpha = 1.0; }
            completion:^(BOOL finished) {
                button.enabled = YES;

            }];
      }
      [[QZBSessionManager sessionManager] newQuestionStart];
  });
}

- (void)UNShowQuestinAndAnswers {
  //[self setScores];

  static float unShowTime = 0.1;

  __weak typeof(self) weakSelf = self;

  [UIView animateWithDuration:unShowTime
                   animations:^{ weakSelf.qestionLabel.alpha = .0; }];

  for (UIButton *button in weakSelf.answerButtons) {
    // button.backgroundColor = [UIColor whiteColor];
    button.enabled = NO;
    [UIView animateWithDuration:unShowTime
        animations:^{ button.alpha = .0; }
        completion:^(BOOL finished) {
            button.enabled = YES;
            QZBAnswerButton *b = (QZBAnswerButton *)button;
            [b unshowTriangles];
        }];
  }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  if ([keyPath isEqualToString:@"currentTime"]) {
    NSUInteger num = [[QZBSessionManager sessionManager] sessionTime] -
                     [[change objectForKey:@"new"] integerValue];

    self.timeLabel.text = [NSString stringWithFormat:@"%ld", num];
  }
}

#pragma mark - recievers

//принимает нотификейшен о необходимости закрыть вопрос из QZBSessionManager
- (void)unshowQuestionNotification:(NSNotification *)notification {
  if ([[notification name] isEqualToString:@"QZBNeedUnshowQuestion"]) {
    [self setScores];

    [self showResultOfQuestion];

    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                 (int64_t)(3 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{

        [self UNShowQuestinAndAnswers];
        [self prepareQuestion];
        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
            dispatch_get_main_queue(), ^{ [weakSelf showQuestinAndAnswers]; });
    });
  }
}

- (void)showResultOfQuestion {
  QZBQuestionWithUserAnswer *qanda =
      [QZBSessionManager sessionManager].opponentUserLastAnswer;
  if (qanda) {
    
    NSUInteger num = qanda.answer.answerNum;
    NSInteger right = qanda.question.rightAnswer;

    for (QZBAnswerButton *b in self.answerButtons) {
      b.enabled = NO;
      if (b.tag == num) {
        [b addTriangleRight];
      }
      if (b.tag != right) {
        [UIView animateWithDuration:0.2
            animations:^{ b.alpha = 0; }
            completion:^(BOOL finished){

            }];
      } else {
        b.backgroundColor = [UIColor greenColor];
        ;
      }
    }
  }
}
//принимает нотификейшен о окончании сессии из QZBSessionManager
- (void)endGameSession:(NSNotification *)notification {
  if ([[notification name] isEqualToString:@"QZBNeedFinishSession"]) {
    [self setScores];
    [self showResultOfQuestion];
    [self UNShowQuestinAndAnswers];
    NSLog(@"session ended");

    self.roundLabel.text = (NSString *)notification.object;

    [UIView animateWithDuration:0.3
        animations:^{ self.roundLabel.alpha = 1.0; }
        completion:^(BOOL finished){

        }];

    __weak typeof(self) weakSelf = self;

    dispatch_after(
        dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)),
        dispatch_get_main_queue(), ^{
            [weakSelf performSegueWithIdentifier:@"gameEnded" sender:nil];

        });
  }
}

- (void)opponentMadeChoose:(NSNotification *)notification {
  if ([[notification name] isEqualToString:@"QZBOpponentUserMadeChoose"]) {
    [self setScores];
  }
}

#pragma mark -

- (void)setScores {
  self.firstUserScore.text =
      [NSString stringWithFormat:@"%ld", [QZBSessionManager sessionManager]
                                             .firstUserScore];
  self.opponentScore.text =
      [NSString stringWithFormat:@"%ld", [QZBSessionManager sessionManager]
                                             .secondUserScore];
}

- (void)setPointersOfChoosedAnswers {
}

@end
