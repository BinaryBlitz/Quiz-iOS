//
//  QZBNewQuestionController.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 13/09/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBNewQuestionController.h"
#import "UIViewController+QZBControllerCategory.h"
#import "UIView+QZBShakeExtension.h"
#import "QZBServerManager.h"
#import <TSMessage.h>
#import <SVProgressHUD.h>
//#import "QZBNewQuestionInputCell.h"
//#import "QZBNewQuestionAnswerCell.h"

// NSString *const QZBNewQuestionInputCellIdentifier  = @"QZBNewQuestionInputCellIdentifier";
// NSString *const QZBNewQuestionAnswerCellIdentifier = @"QZBNewQuestionAnswerCellIdentifier";
// NSString *const QZBNewQuestionSubmitCellIdentifier = @"QZBNewQuestionSubmitCellIdentifier";

@interface QZBNewQuestionController () <UITextViewDelegate, UITextFieldDelegate>

@end

@implementation QZBNewQuestionController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initStatusbarWithColor:[UIColor blackColor]];
    self.title = @"Добавление вопроса";

    for (int i = 0; i < self.answersTextFields.count; i++) {
        UITextField *tf = self.answersTextFields[i];
        NSString *placeholder = @"Ответ";
        if (i == 0) {
            placeholder = [placeholder stringByAppendingString:@" (правильный)"];
        }
        tf.delegate = self;
        tf.placeholder = placeholder;
    }
    self.inputTextView.text = @"";
    [self.inputTextView becomeFirstResponder];
    self.inputTextView.delegate = self;

    self.tabBarController.hidesBottomBarWhenPushed = YES;

    self.inputTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.inputTextView.layer.borderWidth = 0.5;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//
//    // Return the number of sections.
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//
//    // Return the number of rows in the section.
//    return 6;
//}
//
//
//- (UITableViewCell *)tableView:(UITableView *)tableView
//         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if(indexPath.row == 0){
//        QZBNewQuestionInputCell *cell =
//        [tableView
//         dequeueReusableCellWithIdentifier:QZBNewQuestionInputCellIdentifier];
//        cell.inputTextView.text = @"";
//
//        return cell;
//    } else if (indexPath.row == 5){
//        UITableViewCell *cell = [tableView
//        dequeueReusableCellWithIdentifier:QZBNewQuestionSubmitCellIdentifier];
//        return cell;
//    }else {
//        QZBNewQuestionAnswerCell *cell =
//        [tableView dequeueReusableCellWithIdentifier:QZBNewQuestionAnswerCellIdentifier];
//        cell.answerTextField.tag = indexPath.row - 1;
//        [self.answersTextFields addObject:cell.answerTextField];
//        return cell;
//    }
//}
//
#pragma mark - UITableViewDelegate

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if(indexPath.row == 0){
//        return 200.0;
//    } else if(indexPath.row == 5){
//        return 80.0;
//    } else {
//        return 55.0;
//
//    }
//}

#pragma mark - actions

- (IBAction)submitQuestion:(id)sender {
    //[self submitQuestion];
    if ([self isQuestionFilled] && [self isAnswersFilled]) {
        [self submitQuestion];
    }
}
- (void)submitQuestion {
    if ([self isQuestionFilled] && [self isAnswersFilled]) {
        NSString *question = self.inputTextView.text;
        if (!question) {
            return;
        }
        NSMutableArray *arr = [NSMutableArray array];
        for (UITextField *tf in self.answersTextFields) {
            NSString *answer = tf.text;
            if (answer) {
                [arr addObject:answer];
            } else {
                return;
            }
        }
        NSString *rightAnswer = [arr firstObject];

        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [[QZBServerManager sharedManager] POSTNewQuestionWithText:question
            answers:[NSArray arrayWithArray:arr]
            rightAnswer:rightAnswer
            onSuccess:^{

                [SVProgressHUD showSuccessWithStatus:@"Вопрос отправлен"];
                [self clearAllFields];
            }
            onFailure:^(NSError *error, NSInteger statusCode) {
                [SVProgressHUD showErrorWithStatus:QZBNoInternetConnectionMessage];

            }];
    }
}

- (BOOL)isQuestionFilled {
    if (self.inputTextView.text.length == 0) {
        [self.tableView scrollsToTop];
        [self.inputTextView becomeFirstResponder];
        [self.inputView shakeView];
        [TSMessage showNotificationWithTitle:@"Введите вопрос"
                                        type:TSMessageNotificationTypeWarning];
        return NO;
    }

    return YES;
}

- (BOOL)isAnswersFilled {
    for (UITextField *tf in self.answersTextFields) {
        if (tf.text.length == 0) {
            [self markAnswer:tf];
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

- (void)clearAllFields {
    self.inputTextView.text = @"";
    for (UITextField *tf in self.answersTextFields) {
        tf.text = @"";
    }
    [self.inputTextView resignFirstResponder];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath
*)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath]
withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new
row to the table view
    }
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before
navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITextFieldDelegate

- (BOOL)textView:(UITextView *)textView
    shouldChangeTextInRange:(NSRange)range
            replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        if (![self isQuestionFilled]) {
            return NO;
        }
        // [textView resignFirstResponder];
        UITextField *tf = [self.answersTextFields firstObject];

        [tf becomeFirstResponder];
        return NO;
    }

    return YES;
}

#pragma mark - UItextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length == 0) {
        [self markAnswer:textField];
        return NO;
    }

    NSInteger index = [self.answersTextFields indexOfObject:textField];
    if (index != 3) {
        UITextField *tf = self.answersTextFields[index + 1];
        [tf becomeFirstResponder];
    } else {
        [self submitQuestion];
    }
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
