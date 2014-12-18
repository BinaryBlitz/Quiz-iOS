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

@interface QZBGameSessionViewController ()

//@property (strong, nonatomic) QZBSession *session;
//@property(strong, nonatomic) NSTimer *timer;
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

  // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
  //[self prepareQestion:0];
  [self prepareQuestion];
  [self showQuestinAndAnswers];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - actions

- (IBAction)pressAnswerButton:(UIButton *)sender {
  // NSLog(@"%ld", (long)sender.tag);
  [[QZBSessionManager sessionManager]
      firstUserAnswerCurrentQuestinWithAnswerNumber:sender.tag];
  self.firstUserScore.text = [NSString
      stringWithFormat:@"%ld",
                       (unsigned long)
                           [[QZBSessionManager sessionManager] firstUserScore]];

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

  [UIView animateWithDuration:0.1
                   animations:^{ weakSelf.qestionLabel.alpha = 1.0; }];

  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
                 dispatch_get_main_queue(), ^{
      for (UIButton *button in weakSelf.answerButtons) {
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
  static float unShowTime = 0.1;

  __weak typeof(self) weakSelf = self;

  [UIView animateWithDuration:unShowTime
                   animations:^{
                       weakSelf.qestionLabel.alpha = .0;

                   }];

  for (UIButton *button in weakSelf.answerButtons) {
    button.enabled = NO;
    [UIView animateWithDuration:unShowTime
        animations:^{ button.alpha = .0; }
        completion:^(BOOL finished) { button.enabled = YES; }];
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
    __weak typeof(self) weakSelf = self;
    [self UNShowQuestinAndAnswers];
    [self prepareQuestion];
    dispatch_after(
        dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
        dispatch_get_main_queue(), ^{ [weakSelf showQuestinAndAnswers]; });
  }
}

//принимает нотификейшен о окончании сессии из QZBSessionManager
- (void)endGameSession:(NSNotification *)notification {
  if ([[notification name] isEqualToString:@"QZBNeedFinishSession"]) {
    NSLog(@"session ended");
  }
}

@end
