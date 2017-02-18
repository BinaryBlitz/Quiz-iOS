#import "QZBRatingMainVC.h"
#import "QZBRatingPageVC.h"
#import "QZBCategory.h"
#import "QZBGameTopic.h"
#import "QZBServerManager.h"
#import "QZBPlayerPersonalPageVC.h"
#import <SVProgressHUD.h>
#import "UIViewController+QZBControllerCategory.h"
#import "UIFont+QZBCustomFont.h"
#import <DDLog.h>
static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface QZBRatingMainVC ()

@property (strong, nonatomic) id<QZBUserProtocol> user;
@property (assign, nonatomic) BOOL fromTopics;

@property (assign, nonatomic) BOOL isLoaded;
//@property (strong, nonatomic) UIView *buttonBackgroundView;

@end

@implementation QZBRatingMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.multipleTouchEnabled = NO;

    [self setNeedsStatusBarAppearanceUpdate];
    self.typeChooserSegmentControl.exclusiveTouch = YES;
    [self.chooseTopicButton setExclusiveTouch:YES];
    [self initStatusbarWithColor:[UIColor whiteColor]];

    self.typeChooserSegmentControl.exclusiveTouch = YES;
    [self.typeChooserSegmentControl addTarget:self
                                       action:@selector(typeChangedAction:)
                             forControlEvents:UIControlEventValueChanged];

    UIFont *font = [UIFont boldMuseoFontOfSize:14.0f];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    [self.typeChooserSegmentControl setTitleTextAttributes:attributes
                                                  forState:UIControlStateNormal];
}

- (void)initWithTopic:(QZBGameTopic *)topic {
    self.fromTopics = YES;
    self.topic = topic;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadRatingTableViews)
                                                 name:QZBNeedReloadRatingTableView
                                               object:nil];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setExclusiveTouch:YES];
    button.frame = CGRectMake(0, 0, 20, 20);
    [button setImage:[UIImage imageNamed:@"nextIcon"] forState:UIControlStateNormal];
    [button addTarget:self
                  action:@selector(showAnother:)
        forControlEvents:UIControlEventTouchUpInside];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];

    if (!self.isLoaded) {
        self.isLoaded = YES;
        [self reloadRatingTableViews];
    }

    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    [self.navigationController.navigationBar
        setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self addLineUnderButtons];
}

- (void)setRatingWithCategoryID:(NSInteger)categoryID {
    QZBRatingPageVC *pageVC = (QZBRatingPageVC *)[self.childViewControllers firstObject];

    [self setEmptyArrays];
    [[QZBServerManager sharedManager] GETRankingWeekly:NO
        isCategory:YES
        forFriends:NO
        withID:categoryID
        onSuccess:^(NSArray *topRanking, NSArray *playerRanking) {

            [pageVC setAllTimeRanksWithTop:topRanking playerArray:playerRanking];
        }
        onFailure:^(NSError *error, NSInteger statusCode){

        }];

    [[QZBServerManager sharedManager] GETRankingWeekly:YES
        isCategory:YES
        forFriends:NO
        withID:categoryID
        onSuccess:^(NSArray *topRanking, NSArray *playerRanking) {
            [pageVC setWeekRanksWithTop:topRanking playerArray:playerRanking];
        }
        onFailure:^(NSError *error, NSInteger statusCode){

        }];

    [[QZBServerManager sharedManager] GETRankingWeekly:NO
        isCategory:YES
        forFriends:YES
        withID:categoryID
        onSuccess:^(NSArray *topRanking, NSArray *playerRanking) {
            [pageVC setFriendsRanksWithTop:topRanking playerArray:playerRanking];
        }
        onFailure:^(NSError *error, NSInteger statusCode){

        }];
}

- (void)setRatingWithTopicID:(NSInteger)topicID {
    QZBRatingPageVC *pageVC = (QZBRatingPageVC *)[self.childViewControllers firstObject];
    [self setEmptyArrays];

    [[QZBServerManager sharedManager] GETRankingWeekly:NO
        isCategory:NO
        forFriends:NO
        withID:topicID
        onSuccess:^(NSArray *topRanking, NSArray *playerRanking) {
            [pageVC setAllTimeRanksWithTop:topRanking playerArray:playerRanking];
        }
        onFailure:^(NSError *error, NSInteger statusCode){

        }];

    [[QZBServerManager sharedManager] GETRankingWeekly:YES
        isCategory:NO
        forFriends:NO
        withID:topicID
        onSuccess:^(NSArray *topRanking, NSArray *playerRanking) {
            [pageVC setWeekRanksWithTop:topRanking playerArray:playerRanking];
        }
        onFailure:^(NSError *error, NSInteger statusCode){

        }];
    [[QZBServerManager sharedManager] GETRankingWeekly:NO
        isCategory:NO
        forFriends:YES
        withID:topicID
        onSuccess:^(NSArray *topRanking, NSArray *playerRanking) {
            [pageVC setFriendsRanksWithTop:topRanking playerArray:playerRanking]; 
        }
        onFailure:^(NSError *error, NSInteger statusCode){

        }];
}

- (void)setEmptyArrays {
    QZBRatingPageVC *pageVC = (QZBRatingPageVC *)[self.childViewControllers firstObject];

    [pageVC setWeekRanksWithTop:[NSArray array] playerArray:[NSArray array]];
    [pageVC setAllTimeRanksWithTop:[NSArray array] playerArray:[NSArray array]];
    [pageVC setFriendsRanksWithTop:[NSArray array] playerArray:[NSArray array]];
}

- (void)reloadRatingTableViews {
    if (self.topic) {
        NSString *title = nil;

        if (self.fromTopics) {
            title = self.topic.name;
            self.chooseTopicButton.enabled = NO;

            self.navigationItem.rightBarButtonItem = nil;
        } else {
            // self.navigationItem.rightBarButtonItem = nil;

            title = [NSString stringWithFormat:@"%@", self.topic.name];
        }

        [self.chooseTopicButton setTitle:title forState:UIControlStateNormal];

        [self setRatingWithTopicID:[self.topic.topic_id integerValue]];

    } else if (self.category) {
        NSString *title = [NSString stringWithFormat:@"%@", self.category.name];

        [self.chooseTopicButton setTitle:title forState:UIControlStateNormal];

        [self setRatingWithCategoryID:[self.category.category_id integerValue]];

    } else {
        [self.chooseTopicButton setTitle:@"Все темы" forState:UIControlStateNormal];
        [self setRatingWithTopicID:0];
    }
}

#pragma mark - Navigation

- (void)showUserPage:(id<QZBUserProtocol>)user {
    self.user = user;
    [self performSegueWithIdentifier:@"showUser" sender:nil];

    DDLogInfo(@"destination user %@", [user name]);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showUser"]) {
        QZBPlayerPersonalPageVC *vc = segue.destinationViewController;
        [vc initPlayerPageWithUser:self.user];
    }
}

#pragma mark - actions

- (void)showAnother:(id)sender {
    [self performSegueWithIdentifier:@"showCategories" sender:nil];
}

#pragma mark - page choose

- (void)typeChangedAction:(UISegmentedControl *)sender {
    [self ignoreIteractions];

    if ([[self.childViewControllers firstObject] isKindOfClass:[QZBRatingPageVC class]]) {
        QZBRatingPageVC *pvc = [self.childViewControllers firstObject];

        switch (sender.selectedSegmentIndex) {
            case 0:
                [pvc showLeftVC];
                break;
            case 1:
                [pvc showCenterVC];
                break;
            case 2:
                [pvc showRightVC];
                break;
            default:
                break;
        }
    }
}

#pragma mark - ui init

- (void)addLineUnderButtons {
    UIBezierPath *path = [[UIBezierPath alloc] init];
    UIView *destView = self.buttonsBackgroundView.superview;
    CGRect mainR = [UIScreen mainScreen].bounds;
    CGRect r = destView.frame;
    CGPoint beginPoint = CGPointMake(r.size.height + r.origin.x - 1, 0);
    CGPoint endPoint = CGPointMake(r.size.height + r.origin.x - 1, mainR.size.width);
    [path moveToPoint:beginPoint];
    [path addLineToPoint:endPoint];
}

#pragma mark - lazy init

- (UIView *)buttonBackgroundView {
    if (_buttonBackgroundView) {
        [self createButtonBackgroundView];
    }
    return _buttonBackgroundView;
}

- (void)createButtonBackgroundView {
    if (!_buttonBackgroundView) {
        [self.buttonsBackgroundView setNeedsDisplay];
        CGSize backSize = self.buttonsBackgroundView.frame.size;
        NSLog(@"back size %f", backSize.width / 2.0);
        CGRect r = CGRectMake(1, 1, backSize.width / 2.0, 38);
        _buttonBackgroundView = [[UIView alloc] initWithFrame:r];
        _buttonBackgroundView.layer.cornerRadius = 5.0;
        _buttonBackgroundView.layer.masksToBounds = YES;
        _buttonBackgroundView.backgroundColor = [UIColor whiteColor];
        [_buttonsBackgroundView addSubview:_buttonBackgroundView];
        [_buttonsBackgroundView sendSubviewToBack:_buttonBackgroundView];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - lazy

- (void)setTopic:(QZBGameTopic *)topic {
    self.isLoaded = NO;
    _topic = topic;
}

- (void)setCategory:(QZBCategory *)category {
    self.isLoaded = NO;
    _category = category;
}

@end
