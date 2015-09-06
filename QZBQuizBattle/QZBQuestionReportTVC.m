//
//  QZBQuestionReportTVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 28/08/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBQuestionReportTVC.h"
#import "QZBQuestion.h"
#import "QZBAnswerTextAndID.h"
#import "QZBTopicWorker.h"
#import "QZBCategory.h"
#import "QZBServerManager.h"

// cells
#import "QZBQuestionReportQuestionTextCell.h"
#import "QZBQuestionReportPictureCell.h"
#import "QZBQuestuinReportAnswerCell.h"
#import "QZBQuestionReportButtonCell.h"

#import <DFImageManager/DFImageManager.h>
#import <DFImageManager/DFImageRequestOptions.h>
#import <DFImageManager/DFURLImageFetcher.h>
#import <DFImageManager/DFImageRequest.h>
#import <DFImageManager/DFImageView.h>

#import <SVProgressHUD.h>

#import <TSMessages/TSMessage.h>

#import "UIViewController+QZBControllerCategory.h"
#import "UIColor+QZBProjectColors.h"
#import "UIFont+QZBCustomFont.h"

NSString *const QZBQuestionReportTextCellIdentifier = @"QZBQuestionCellIdentifier";
NSString *const QZBQuestionReportImageCellIdentifier = @"QZBQuestionReportImageCellIdentifier";
NSString *const QZBQuestionReportAnswerCellIdentifier = @"QZBQuestionAnswerCellIdentifier";
NSString *const QZBQuestionReportEmptyCellIdentifier = @"questionReportEmptyCellIdentifier";
NSString *const QZBQuestionReportButtonCellIdentifier = @"QZBQuestionButtonCellIdentifier";

NSString *const QZBReportSendedMessage = @"Жалоба успешно отправлена";

@interface QZBQuestionReportTVC ()

@property (strong, nonatomic) NSArray *questions;
@property (assign, nonatomic) CGFloat imageHeight;
@property (strong, nonatomic) UIImage *rightImage;

@property (strong, nonatomic) NSMutableDictionary *offscreenCells;

@property (strong, nonatomic) QZBQuestionReportQuestionTextCell *protoCell;

@property (strong, nonatomic) QZBGameTopic *topic;

@end

@implementation QZBQuestionReportTVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.imageHeight = [UIScreen mainScreen].bounds.size.width * 9.0 / 16.0;

    [self initStatusbarWithColor:[UIColor blackColor]];

    self.title = @"Вопросы";

    self.rightImage = [[UIImage imageNamed:@"checkIcon"]
        imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.tabBarController setHidesBottomBarWhenPushed:NO];

    //    self.tableView.contentInset =
    //        UIEdgeInsetsMake(0., 0., CGRectGetHeight(self.tabBarController.tabBar.frame), 0);

      self.tableView.tableFooterView = [[UIView alloc]
                                        initWithFrame:CGRectMake(0,
                                                                 0,
                                                                 [UIScreen mainScreen].bounds.size.width,
                                                                 50)];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view
    // controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configureBackgroundImage];
    self.tabBarController.tabBar.hidden = NO;

    [self.tabBarController setHidesBottomBarWhenPushed:NO];

    //    self.tableView.contentInset =
    //    UIEdgeInsetsMake(0., 0., CGRectGetHeight(self.tabBarController.tabBar.frame), 0);
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
     self.tabBarController.tabBar.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureWithQuestions:(NSArray *)questions topic:(QZBGameTopic *)topic {
    self.topic = topic;
    self.questions = questions;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return self.questions.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.

    // QZBQuestion *q = self.questions[section];
    NSInteger count = 7;

    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QZBQuestion *q = self.questions[indexPath.section];

    if (indexPath.row == 0) {
        QZBQuestionReportQuestionTextCell *cell =
            [tableView dequeueReusableCellWithIdentifier:QZBQuestionReportTextCellIdentifier];
        cell.questionLabel.text = q.question;
        [cell updateConstraintsIfNeeded];
        cell.questionLabel.preferredMaxLayoutWidth = CGRectGetWidth(tableView.bounds);
        return cell;
    } else if (indexPath.row == 1) {
        if (q.imageURL) {
            QZBQuestionReportPictureCell *cell =
                [tableView dequeueReusableCellWithIdentifier:QZBQuestionReportImageCellIdentifier];
            [self configureImage:cell.questionImageView withQuest:q];
            return cell;

        } else {
            UITableViewCell *cell =
                [tableView dequeueReusableCellWithIdentifier:QZBQuestionReportEmptyCellIdentifier];

            return cell;
        }

    } else if (indexPath.row > 1 && indexPath.row < 6) {
        QZBQuestuinReportAnswerCell *cell =
            [tableView dequeueReusableCellWithIdentifier:QZBQuestionReportAnswerCellIdentifier];

        QZBAnswerTextAndID *answer = q.answers[indexPath.row - 2];

        cell.answerLabel.text = answer.answerText;

        if (answer.answerID == q.rightAnswer) {
            cell.answerLabel.textColor = [UIColor lightGreenColor];
            cell.isRightImageView.image = self.rightImage;
            cell.isRightImageView.tintColor = [UIColor lightGreenColor];
        } else {
            cell.answerLabel.textColor = [UIColor whiteColor];
            cell.isRightImageView.image = nil;
        }

        return cell;
    } else if (indexPath.row == 6) {
        QZBQuestionReportButtonCell *cell =
            [tableView dequeueReusableCellWithIdentifier:QZBQuestionReportButtonCellIdentifier];

        return cell;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];

    view.backgroundColor =
        [UIColor colorWithWhite:0.0 alpha:1.0];  //[self colorForSection:section];

    CGRect rect = CGRectMake(0, 7, CGRectGetWidth(tableView.frame), 42);

    UILabel *label = [[UILabel alloc] initWithFrame:rect];

    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldMuseoFontOfSize:20];

    //    if (section > 0) {
    //        [view addDropShadowsForView];
    //    }
    //
    [view addSubview:label];

    // NSArray *arr = self.workArray[section];

    label.text =
        [NSString stringWithFormat:@"Вопрос %@",
                                   @(section + 1)];  //[[self textForArray:arr] uppercaseString];

    return view;
}

- (void)configureImage:(DFImageView *)image withQuest:(QZBQuestion *)question {
    DFImageRequestOptions *options = [DFImageRequestOptions new];
    options.allowsClipping = YES;

    options.userInfo = @{ DFURLRequestCachePolicyKey : @(NSURLRequestReturnCacheDataElseLoad) };

    DFImageRequest *request = [DFImageRequest requestWithResource:question.imageURL
                                                       targetSize:CGSizeZero
                                                      contentMode:DFImageContentModeAspectFill
                                                          options:options];

    image.allowsAnimations = YES;
    image.allowsAutoRetries = YES;

    [image prepareForReuse];

    [image setImageWithRequest:request];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    QZBQuestion *q = self.questions[indexPath.section];

    if (indexPath.row == 0) {
        return 100.0;

    } else if (indexPath.row == 1) {
        if (q.imageURL)
            return self.imageHeight;
        else
            return 1.0;
    } else if (indexPath.row == 6) {
        return 55.0;
    }

    return 44.0;
}
//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath
//*)indexPath
//{
//    // Do the minimal calculations required to be able to return an
//    // estimated row height that's within an order of magnitude of the
//    // actual height. For example:
//
//        return 44.0f;
//
//}

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

#pragma mark - action

- (IBAction)makeReport:(UIButton *)sender {
   QZBQuestionReportButtonCell *cell = (QZBQuestionReportButtonCell *)[self parentCellForView:sender];
    if (cell) {
      
        NSIndexPath *ip = [self.tableView indexPathForCell:cell];

        QZBQuestion *q = self.questions[ip.section];
//        cell.reportButton.enabled = NO;
//        [cell.reportButton setTitle:@"" forState:UIControlStateDisabled];
//        cell.reportActivityIndicator.hidden = NO;
//        [cell.reportActivityIndicator startAnimating];
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        
        [[QZBServerManager sharedManager] POSTReportForQuestionWithID:q.questionId
            message:@"report"
            onSuccess:^{
                [SVProgressHUD showSuccessWithStatus:QZBReportSendedMessage];
//                [TSMessage showNotificationWithTitle:QZBReportSendedMessage
//                                                type:TSMessageNotificationTypeSuccess];
//                [cell.reportActivityIndicator stopAnimating];
//                cell.reportActivityIndicator.hidden = YES;
//                [cell.reportButton setTitle:@"Отправлено" forState:UIControlStateDisabled];
                

            }
            onFailure:^(NSError *error, NSInteger statusCode) {
                [SVProgressHUD showErrorWithStatus:QZBNoInternetConnectionMessage];
//                cell.reportButton.enabled = YES;
//                [cell.reportButton setTitle:@"Пожаловаться" forState:UIControlStateNormal];
//                [cell.reportActivityIndicator stopAnimating];
//                cell.reportActivityIndicator.hidden = YES;

//                [TSMessage showNotificationWithTitle:QZBNoInternetConnectionMessage
//                                                type:TSMessageNotificationTypeSuccess];
                // TEST
//
//                            [TSMessage showNotificationWithTitle:QZBNoInternetConnectionMessage
//                                                            type:TSMessageNotificationTypeError];

            }];

        NSLog(@"num %ld", (long)q.questionId);
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (NSMutableDictionary *)offscreenCells {
    if (!_offscreenCells) {
        _offscreenCells = [NSMutableDictionary dictionary];
    }
    return _offscreenCells;
}

- (QZBQuestionReportQuestionTextCell *)protoCell {
    if (!_protoCell) {
        _protoCell =
            [self.tableView dequeueReusableCellWithIdentifier:QZBQuestionReportTextCellIdentifier];
    }
    return _protoCell;
}

#pragma mark - background img

- (void)configureBackgroundImage {
    QZBGameTopic *topic = self.topic;
    if (!topic) {
        return;
    }
    QZBCategory *category = [QZBTopicWorker tryFindRelatedCategoryToTopic:topic];
    if (category) {
        NSURL *url = [NSURL URLWithString:category.background_url];

        CGRect r = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds),
                              16 * CGRectGetWidth([UIScreen mainScreen].bounds) / 9);

        DFImageView *dfiIV = [[DFImageView alloc] initWithFrame:r];

        self.tableView.backgroundColor = [UIColor clearColor];

        DFImageRequestOptions *options = [DFImageRequestOptions new];
        options.allowsClipping = YES;

        options.userInfo = @{ DFURLRequestCachePolicyKey : @(NSURLRequestReturnCacheDataElseLoad) };

        DFImageRequest *request = [DFImageRequest requestWithResource:url
                                                           targetSize:CGSizeZero
                                                          contentMode:DFImageContentModeAspectFill
                                                              options:options];

        dfiIV.allowsAnimations = NO;
        dfiIV.allowsAutoRetries = YES;

        [dfiIV prepareForReuse];

        [dfiIV setImageWithRequest:request];

        self.tableView.backgroundView = dfiIV;
    }
}

@end
