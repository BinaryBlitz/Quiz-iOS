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

@interface QZBTopicChooserControllerViewController () 
@property (strong, nonatomic) NSArray *topics;
@property(strong, nonatomic) QZBCategory *category;
@property (strong, nonatomic) QZBGameTopic *choosedTopic;

@end

@implementation QZBTopicChooserControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setNeedsStatusBarAppearanceUpdate];
    
    self.topicTableView.delegate = self;
    self.topicTableView.dataSource = self;
    
    [self.navigationController.navigationBar  setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBackIndicatorImage:[UIImage imageNamed:@"backWhiteIcon"]];

    
   // self.navigationController.navigationBar.barTintColor = [UIColor redColor];
   //
   // [UINavigationBar appearance] setTitleTextAttributes:@{}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //self.navigationController.navigationBar.barTintColor = [UIColor redColor];

    self.navigationItem.hidesBackButton = NO;
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor redColor]];
    [self.navigationController.navigationBar  setTitleTextAttributes:@{[UIColor whiteColor]: NSForegroundColorAttributeName}];
    
    [self.navigationController.navigationBar  setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBackIndicatorImage:[UIImage imageNamed:@"backWhiteIcon"]];
    [self.navigationController.navigationBar setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"backWhiteIcon"]];
    
    
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = NO;
    
    //self.navigationController.navigationBar.topItem.title = @"";
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
// preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showPreparingVC"]) {
        QZBProgressViewController *navigationController = segue.destinationViewController;
        navigationController.topic = self.choosedTopic;
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.topics count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"topicCell";

    QZBTopicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    QZBGameTopic *topic = (QZBGameTopic *)self.topics[indexPath.row];

    cell.topicName.text = topic.name;

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    self.choosedTopic = self.topics[indexPath.row];
    NSLog(@"%ld", (long)self.choosedTopic.topic_id);

    [self performSegueWithIdentifier:@"showPreparingVC" sender:nil];
}

#pragma mark - topics init

- (void)initTopicsWithCategory:(QZBCategory *)category {
    // NSLog(@"category name:  %@", category.name);
    
    self.category = category;

    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];

    self.topics =
        [[NSArray arrayWithArray:[[category relationToTopic] allObjects]] sortedArrayUsingDescriptors:@[ sort ]];

    self.title = category.name;

    //  NSInteger category_id = [category.category_id integerValue];

    [[QZBServerManager sharedManager] getTopicsWithCategory:category
        onSuccess:^(NSArray *topics) {
          self.topics =
              [[NSArray arrayWithArray:[[category relationToTopic] allObjects]] sortedArrayUsingDescriptors:@[ sort ]];
          [self.topicTableView reloadData];

        }
        onFailure:^(NSError *error, NSInteger statusCode){

        }];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
@end
