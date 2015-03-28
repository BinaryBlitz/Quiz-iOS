//
//  QZBTopicChooserControllerViewController.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 24/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import "QZBTopicChooserControllerViewController.h"
#import "QZBProgressViewController.h"
#import "QZBTopicTableViewCell.h"
#import "QZBGameTopic.h"
#import "QZBServerManager.h"
#import "QZBCategory.h"
#import "CoreData+MagicalRecord.h"
#import "QZBRatingMainVC.h"
#import "QZBFriendsChallengeTVC.h"
#import "QZBCurrentUser.h"
#import "UIViewController+QZBControllerCategory.h"

@interface QZBTopicChooserControllerViewController ()
@property (strong, nonatomic) NSArray *topics;
@property (strong, nonatomic) QZBCategory *category;
//@property (strong, nonatomic) QZBGameTopic *choosedTopic;
@property (strong, nonatomic) NSIndexPath *choosedIndexPath;
@property (strong, nonatomic) id<QZBUserProtocol> user;

@end

@implementation QZBTopicChooserControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setNeedsStatusBarAppearanceUpdate];

    self.topicTableView.delegate = self;
    self.topicTableView.dataSource = self;

    UIBarButtonItem *backButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@""
                                         style:UIBarButtonItemStylePlain
                                        target:nil
                                        action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];

    [self.navigationController.navigationBar
        setBackIndicatorImage:[UIImage imageNamed:@"backWhiteIcon"]];
    [self.navigationController.navigationBar
        setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"backWhiteIcon"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.hidesBackButton = NO;
    [[self navigationController] setNavigationBarHidden:NO animated:NO];

    [self.navigationController.navigationBar
        setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];

    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];

    [self.navigationController.navigationBar
        setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = NO;

    // self.navigationController.navigationBar.topItem.title = @"";
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
// preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showPreparingVC"]) {
        QZBProgressViewController *navigationController = segue.destinationViewController;
        //   navigationController.topic = self.choosedTopic;

        [navigationController initSessionWithTopic:self.choosedTopic user:self.user];

    } else if ([segue.identifier isEqualToString:@"showRate"]) {
        QZBRatingMainVC *destinationVC = segue.destinationViewController;
        [destinationVC initWithTopic:self.choosedTopic];
    } else if ([segue.identifier isEqualToString:@"showFriendsChallenge"]) {
        QZBFriendsChallengeTVC *destinationVC = segue.destinationViewController;
        QZBUser *user = [QZBCurrentUser sharedInstance].user;

        [[QZBServerManager sharedManager] GETAllFriendsOfUserWithID:user.userID
            OnSuccess:^(NSArray *friends) {
                [destinationVC setFriendsOwner:user andFriends:friends gameTopic:self.choosedTopic];

            }
            onFailure:^(NSError *error, NSInteger statusCode){

            }];

        //  [destinationVC setFriendsOwner:user andFriends:
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.topics count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"topicCell";
    static NSString *challengeIdentifier = @"topicChallengeCell";

    QZBTopicTableViewCell *cell = nil;
    if (self.user) {
        cell = [tableView dequeueReusableCellWithIdentifier:challengeIdentifier];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    }

    UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
    backView.backgroundColor = [UIColor clearColor];
    cell.backgroundView = backView;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    QZBGameTopic *topic = (QZBGameTopic *)self.topics[indexPath.row];
    
    NSInteger level = 0;
    float progress = 0.0;
    
    [self calculateLevel:&level levelProgress:&progress fromScore:[topic.points integerValue]];
    
    [cell initCircularProgressWithLevel:level progress:progress];
    
    cell.topicName.text = topic.name;

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.user) {
        if ([self.choosedIndexPath isEqual:indexPath]) {
            self.choosedIndexPath = nil;
        } else {
            self.choosedIndexPath = indexPath;
        }

        [tableView beginUpdates];
        [tableView endUpdates];

    } else {
        self.choosedTopic = self.topics[indexPath.row];
        [self performSegueWithIdentifier:@"showPreparingVC" sender:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.choosedIndexPath isEqual:indexPath]) {
        return 120.0f;
    }
    return 74.0f;
}

#pragma actions
//- (UITableViewCell *)parentCellForView:(id)theView {
//    id viewSuperView = [theView superview];
//    while (viewSuperView != nil) {
//        if ([viewSuperView isKindOfClass:[UITableViewCell class]]) {
//            return (UITableViewCell *)viewSuperView;
//        } else {
//            viewSuperView = [viewSuperView superview];
//        }
//    }
//    return nil;
//}

- (IBAction)playButtonAction:(UIButton *)sender {
    UITableViewCell *cell = [self parentCellForView:sender];
    if (cell != nil) {
        NSIndexPath *indexPath = [self.topicTableView indexPathForCell:cell];
        // NSLog(@"show detail for item at row %d", indexPath.row);
        self.choosedTopic = self.topics[indexPath.row];
        NSLog(@"%ld", (long)self.choosedTopic.topic_id);

        [self performSegueWithIdentifier:@"showPreparingVC" sender:nil];
    }
}
- (IBAction)challengeAction:(id)sender {
    UITableViewCell *cell = [self parentCellForView:sender];
    if (cell != nil) {
        NSIndexPath *indexPath = [self.topicTableView indexPathForCell:cell];
        //   NSLog(@"show detail for item at row %d", indexPath.row);
        self.choosedTopic = self.topics[indexPath.row];
        [self performSegueWithIdentifier:@"showFriendsChallenge" sender:nil];
    }
}
- (IBAction)rateAction:(UIButton *)sender {
    UITableViewCell *cell = [self parentCellForView:sender];
    if (cell != nil) {
        NSIndexPath *indexPath = [self.topicTableView indexPathForCell:cell];
        // NSLog(@"show detail for item at row %d", indexPath.row);
        self.choosedTopic = self.topics[indexPath.row];

        [self performSegueWithIdentifier:@"showRate" sender:nil];
    }
}

#pragma mark - custom init

- (void)initWithChallengeUser:(id<QZBUserProtocol>)user category:(QZBCategory *)category {
    self.user = user;
    [self initTopicsWithCategory:category];
}

- (void)initTopicsWithCategory:(QZBCategory *)category {
    self.category = category;

 //   [self.navigationController.navigationBar setBarTintColor:[UIColor redColor]];  // redo for
                                                                                   // colors
    //    self.topicTableView.backgroundColor = [UIColor redColor];

    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];

    self.topics = [[NSArray arrayWithArray:[[category relationToTopic] allObjects]]
        sortedArrayUsingDescriptors:@[ sort ]];

    self.title = category.name;

    //  NSInteger category_id = [category.category_id integerValue];

    [[QZBServerManager sharedManager] getTopicsWithCategory:category
        onSuccess:^(NSArray *topics) {
            self.topics = [[NSArray arrayWithArray:[[category relationToTopic] allObjects]]
                sortedArrayUsingDescriptors:@[ sort ]];
            [self.topicTableView reloadData];

        }
        onFailure:^(NSError *error, NSInteger statusCode){

        }];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
@end
