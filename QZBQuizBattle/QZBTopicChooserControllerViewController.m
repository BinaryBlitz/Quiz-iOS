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
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "NSObject+QZBSpecialCategory.h"
#import "UIColor+QZBProjectColors.h"
#import <JSQSystemSoundPlayer.h>
#import "UIView+QZBShakeExtension.h"

//dfiimage

#import <DFImageManager/DFImageManager.h>
#import <DFImageManager/DFImageRequestOptions.h>
#import <DFImageManager/DFURLImageFetcher.h>
#import <DFImageManager/DFImageRequest.h>
#import <DFImageManager/DFImageView.h>

@interface QZBTopicChooserControllerViewController ()
@property (strong, nonatomic) NSArray *topics;
@property (strong, nonatomic) QZBCategory *category;
@property(strong, nonatomic) UIView *backView;
//@property (strong, nonatomic) QZBGameTopic *choosedTopic;

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

    [self initStatusbarWithColor:[UIColor blackColor]];

    NSURL *url = [NSURL URLWithString:self.category.background_url];
    
    DFImageRequestOptions *options = [DFImageRequestOptions new];
    options.allowsClipping = YES;
    
    options.userInfo = @{ DFURLRequestCachePolicyKey : @(NSURLRequestReturnCacheDataElseLoad) };
    options.expirationAge = 60*60*24*10;
    
    DFImageRequest *request = [DFImageRequest requestWithResource:url
                                                       targetSize:CGSizeZero
                                                      contentMode:DFImageContentModeAspectFill
                                                          options:options];
    
    self.backgroundImageView.allowsAnimations = YES;
    self.backgroundImageView.allowsAutoRetries = YES;
    
    [self.backgroundImageView prepareForReuse];
    
    [self.backgroundImageView setImageWithRequest:request];
    
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
                [destinationVC setFriendsOwner:user
                                    andFriends:friends
                                     gameTopic:self.choosedTopic];

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

    cell.backgroundView = self.backView;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    QZBGameTopic *topic = (QZBGameTopic *)self.topics[indexPath.row];
    
    
    [cell initWithTopic:topic];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[QZBTopicTableViewCell class]]) {
        QZBTopicTableViewCell *topicCell = (QZBTopicTableViewCell *)cell;
        if (!topicCell.visible) {
            self.choosedIndexPath = nil;
            [tableView beginUpdates];
            [tableView endUpdates];
            [self showAlertAboutUnvisibleTopic:topicCell.topicName.text];  // REDO

            return;
        }
    }

    if (!self.user) {
        if ([self.choosedIndexPath isEqual:indexPath]) {
            self.choosedIndexPath = nil;
        } else {
            self.choosedIndexPath = indexPath;
        }

        [[JSQSystemSoundPlayer sharedPlayer] playSoundWithFilename:@"switch"
                                                     fileExtension:kJSQSystemSoundTypeWAV];//REDO
        [tableView beginUpdates];
        [tableView endUpdates];

    } else {
        self.choosedTopic = self.topics[indexPath.row];
        [self performSegueWithIdentifier:@"showPreparingVC" sender:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.choosedIndexPath isEqual:indexPath]) {
       // [JSQSystemSoundPlayer sha]
        return 130.0f;
    }
    return 74.0f;
}



#pragma actions

- (IBAction)playButtonAction:(UIButton *)sender {
    UITableViewCell *cell = [self parentCellForView:sender];

    if ([cell isKindOfClass:[QZBGameTopic class]]) {
        QZBTopicTableViewCell *topicCell = (QZBTopicTableViewCell *)cell;

        if (!topicCell.visible) {
            self.choosedIndexPath = nil;
            [self.topicTableView beginUpdates];
            [self.topicTableView endUpdates];
            return;
        }
    }

    if (cell != nil) {
        NSIndexPath *indexPath = [self.topicTableView indexPathForCell:cell];
        self.choosedTopic = self.topics[indexPath.row];

        [self performSegueWithIdentifier:@"showPreparingVC" sender:nil];
    }
}
- (IBAction)challengeAction:(id)sender {
    UITableViewCell *cell = [self parentCellForView:sender];

    if ([cell isKindOfClass:[QZBGameTopic class]]) {
        QZBTopicTableViewCell *topicCell = (QZBTopicTableViewCell *)cell;

        if (!topicCell.visible) {
            self.choosedIndexPath = nil;
            [self.topicTableView beginUpdates];
            [self.topicTableView endUpdates];
            return;
        }
    }

    if (cell != nil) {
        NSIndexPath *indexPath = [self.topicTableView indexPathForCell:cell];
        self.choosedTopic = self.topics[indexPath.row];
        [self performSegueWithIdentifier:@"showFriendsChallenge" sender:nil];
    }
}
- (IBAction)rateAction:(UIButton *)sender {
    UITableViewCell *cell = [self parentCellForView:sender];

    if ([cell isKindOfClass:[QZBGameTopic class]]) {
        QZBTopicTableViewCell *topicCell = (QZBTopicTableViewCell *)cell;

        if (!topicCell.visible) {
            self.choosedIndexPath = nil;
            [self.topicTableView beginUpdates];
            [self.topicTableView endUpdates];
            return;
        }
    }

    if (cell != nil) {
        NSIndexPath *indexPath = [self.topicTableView indexPathForCell:cell];
        self.choosedTopic = self.topics[indexPath.row];

        [self performSegueWithIdentifier:@"showRate" sender:nil];
    }
}

- (BOOL)checkVisibiliti:(UITableViewCell *)cell {
    if ([cell isKindOfClass:[QZBGameTopic class]]) {
        QZBTopicTableViewCell *topicCell = (QZBTopicTableViewCell *)cell;

        if (!topicCell.visible) {
            self.choosedIndexPath = nil;
            [self.topicTableView beginUpdates];
            [self.topicTableView endUpdates];
        }
        return topicCell.visible;
    }
    return NO;
}

#pragma mark - custom init

- (void)initWithChallengeUser:(id<QZBUserProtocol>)user category:(QZBCategory *)category {
    self.user = user;
    [self initTopicsWithCategory:category];
}

- (void)initTopicsWithCategory:(QZBCategory *)category {
    self.category = category;

    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];

    self.topics = [[NSArray arrayWithArray:[[category relationToTopic] allObjects]]
        sortedArrayUsingDescriptors:@[ sort ]];

    self.title = category.name;

    [[QZBServerManager sharedManager] GETTopicsWithCategory:category
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

#pragma mark -lazy init

-(UIView *)backView{
    if(!_backView){
        _backView = [[UIView alloc] initWithFrame:CGRectZero];
        _backView.backgroundColor = [UIColor clearColor];
    }
    return _backView;
}
@end
