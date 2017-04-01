#import "QZBNewQuestionController.h"
#import "UIViewController+QZBControllerCategory.h"
#import "UIView+QZBShakeExtension.h"
#import "QZBServerManager.h"
#import <TSMessage.h>
#import <SVProgressHUD.h>
#import "QZBNewQuestionInputCell.h"
#import "QZBNewQuestionAnswerCell.h"
#import "QZBTopicTableViewCell.h"

#import "QZBGameTopic.h"

NSString *const QZBNewQuestionInputCellIdentifier = @"QZBNewQuestionInputCellIdentifier";
NSString *const QZBNewQuestionAnswerCellIdentifier = @"QZBNewQuestionAnswerCellIdentifier";
NSString *const QZBNewQuestionSubmitCellIdentifier = @"QZBNewQuestionSubmitCellIdentifier";
static NSString *QZBChooseTopicCellIdentifierInQuest = @"chooseTopicCellIdentifier";
static NSString *QZBTopicCellIdentifierInQuest = @"topicCell";

NSString *const QZBShowCategoryChooserFromNewQuestionSegueIdentifier =
    @"QZBShowCategoryChooserFromNewQuestionSegueIdentifier";

static NSInteger answerOffset = 2;

@interface QZBNewQuestionController () <UITextViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) QZBGameTopic *topic;

@property (strong, nonatomic) NSMutableArray *answers;

@property (strong, nonatomic) NSString *question;

@end

@implementation QZBNewQuestionController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self initStatusbarWithColor:[UIColor blackColor]];
  self.title = @"Добавление вопроса";
  self.tabBarController.hidesBottomBarWhenPushed = YES;

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (self.topic) {
    return 7;
  } else {
    return 6;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 1) {
    QZBNewQuestionInputCell *cell =
        [tableView dequeueReusableCellWithIdentifier:QZBNewQuestionInputCellIdentifier];
    cell.inputTextView.delegate = self;
    cell.inputTextView.text = self.question;

    return cell;
  } else if (indexPath.row == 0) {
    if (self.topic) {
      QZBTopicTableViewCell *cell =
          [tableView dequeueReusableCellWithIdentifier:QZBTopicCellIdentifierInQuest];

      [cell initWithTopic:self.topic];

      return cell;
    } else {
      UITableViewCell *cell =
          [tableView dequeueReusableCellWithIdentifier:QZBChooseTopicCellIdentifierInQuest];

      return cell;
    }
  } else if (indexPath.row == 6) {
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:QZBNewQuestionSubmitCellIdentifier];
    return cell;
  } else {
    QZBNewQuestionAnswerCell *cell =
        [tableView dequeueReusableCellWithIdentifier:QZBNewQuestionAnswerCellIdentifier];
    cell.answerTextField.tag = indexPath.row - 2;
    NSString *placeholder = @"Ответ";
    if (cell.answerTextField.tag == 0) {
      placeholder = [placeholder stringByAppendingString:@" (правильный)"];
      cell.answerTextField.font = [UIFont boldSystemFontOfSize:14.0];
    } else {
      cell.answerTextField.font = [UIFont systemFontOfSize:14.0];
    }
    cell.answerTextField.delegate = self;
    cell.answerTextField.placeholder = placeholder;
    cell.answerTextField.text = self.answers[cell.answerTextField.tag];

    return cell;
  }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 1) {
    return 200.0;
  } else if (indexPath.row == 0) {
    return 79.0;
  } else if (indexPath.row == 6) {
    return 80.0;
  } else {
    return 60.0;
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  if ([cell.reuseIdentifier isEqualToString:QZBChooseTopicCellIdentifierInQuest] ||
      [cell.reuseIdentifier isEqualToString:QZBTopicCellIdentifierInQuest]) {
    [self showCategoryChooser];
  } else if ([cell.reuseIdentifier isEqualToString:QZBNewQuestionSubmitCellIdentifier]) {
    [self submitQuestion];
  }
}

#pragma mark - actions

- (IBAction)submitQuestion:(id)sender {
  if ([self isQuestionFilled] && [self isAnswersFilled]) {
    [self submitQuestion];
  }
}

- (void)submitQuestion {
  if ([self isQuestionFilled] && [self isAnswersFilled] && self.topic) {
    NSString *question = self.question;
    if (!question) {
      return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];

    [[QZBServerManager sharedManager] POSTNewQuestionWithText:question
                                                      answers:self.answers topicID:self.topic.topic_id onSuccess:^{
          [SVProgressHUD showSuccessWithStatus:@"Вопрос отправлен"];
          [self clearAllFields];
        }                                           onFailure:^(NSError *error, NSInteger statusCode) {
          if (statusCode != -1) {
            // [self clearAllFields];
            [SVProgressHUD showErrorWithStatus:QZBNoInternetConnectionMessage];
          }
        }];
  }
}

- (BOOL)isQuestionFilled {

  if (self.question.length == 0) {
    [TSMessage showNotificationWithTitle:@"Введите вопрос"
                                    type:TSMessageNotificationTypeWarning];

    NSIndexPath *ip = [NSIndexPath indexPathForRow:1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:ip
                          atScrollPosition:UITableViewScrollPositionTop animated:YES];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:ip];

    if (cell && [cell isKindOfClass:[QZBNewQuestionInputCell class]]) {
      QZBNewQuestionInputCell *c = (QZBNewQuestionInputCell *) cell;
      [c.inputTextView shakeView];
      [c.inputTextView becomeFirstResponder];
    }

    return NO;
  }

  return YES;
}

- (BOOL)isAnswersFilled {
  for (int i = 0; i < self.answers.count; i++) {
    NSString *s = self.answers[i];
    if (s.length == 0) {
      [self markAnswerWithIndex:i];
      return NO;
    }
  }
  return YES;
}

- (void)markAnswer:(UITextField *)tf {
  [tf shakeView];
  [tf becomeFirstResponder];
  [TSMessage showNotificationWithTitle:@"Введите ответ" type:TSMessageNotificationTypeWarning];
}

- (NSIndexPath *)indexPathForAnswerIndex:(NSInteger)answerIndex {
  return [NSIndexPath indexPathForRow:answerIndex + answerOffset inSection:0];
}

- (void)markAnswerWithIndex:(NSInteger)answerIndex {
  NSIndexPath *ip = [self indexPathForAnswerIndex:answerIndex];
  [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:YES];
  [TSMessage showNotificationWithTitle:@"Введите ответ" type:TSMessageNotificationTypeWarning];

  UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:ip];

  if (cell && [cell isKindOfClass:[QZBNewQuestionAnswerCell class]]) {

    QZBNewQuestionAnswerCell *c = (QZBNewQuestionAnswerCell *) cell;
    [c.answerTextField shakeView];
    [c.answerTextField becomeFirstResponder];
  }
}

- (void)clearAllFields {
  self.question = nil;
  self.answers = nil;
  self.topic = nil;
  [self.tableView reloadData];
}

#pragma mark - UITextViewDelegate

- (BOOL)       textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
        replacementText:(NSString *)text {
  if ([text isEqualToString:@"\n"]) {
    if (![self isQuestionFilled]) {
      return NO;
    }
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    if (cell && [cell isKindOfClass:[QZBNewQuestionAnswerCell class]]) {
      QZBNewQuestionAnswerCell *c = (QZBNewQuestionAnswerCell *) cell;
      [c.answerTextField becomeFirstResponder];
    }
    return NO;
  }
  self.question = [textView.text stringByReplacingCharactersInRange:range withString:text];
  return YES;
}

#pragma mark - UITextFieldDelegate

- (BOOL)            textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
            replacementString:(NSString *)string {
  self.answers[textField.tag] = [textField.text stringByReplacingCharactersInRange:range
                                                                        withString:string];
  return YES;
}

//
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if (textField.text.length == 0) {
    [self markAnswer:textField];
    return NO;
  }

  UITableViewCell *cell = [self parentCellForView:textField];

  if (cell) {
    NSIndexPath *ip = [self.tableView indexPathForCell:cell];
    if (ip.row < 5) {
      NSIndexPath *newIP = [NSIndexPath indexPathForRow:ip.row + 1 inSection:0];
      UITableViewCell *newCell = [self.tableView cellForRowAtIndexPath:newIP];
      if (newCell && [newCell isKindOfClass:[QZBNewQuestionAnswerCell class]]) {
        QZBNewQuestionAnswerCell *newC = (QZBNewQuestionAnswerCell *) newCell;
        [newC.answerTextField becomeFirstResponder];
      }
    }
  }

  return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

#pragma mark - actions

- (void)setUserTopic:(QZBGameTopic *)topic {
  self.topic = topic;
  [self.tableView reloadData];
}

#pragma mark - support

- (void)addBarButtonRight {
  self.navigationItem.rightBarButtonItem =
      [[UIBarButtonItem alloc] initWithTitle:@"Вопросы"
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(showCategoryChooser)];
}

- (void)showCategoryChooser {
  [self performSegueWithIdentifier:QZBShowCategoryChooserFromNewQuestionSegueIdentifier
                            sender:nil];
}

#pragma mark - lazy

- (NSMutableArray *)answers {
  if (!_answers) {
    _answers = [@[@"", @"", @"", @""] mutableCopy];
  }

  return _answers;
}

- (NSString *)question {
  if (!_question) {
    _question = @"";
  }
  return _question;
}

@end
