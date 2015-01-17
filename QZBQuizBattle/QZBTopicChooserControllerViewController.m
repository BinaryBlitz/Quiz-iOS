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

@interface QZBTopicChooserControllerViewController () <UITableViewDataSource,
                                                       UITableViewDelegate>

@property(strong, nonatomic) NSArray *topics;
@property(strong, nonatomic) QZBGameTopic *choosedTopic;

@end

@implementation QZBTopicChooserControllerViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.topicTableView.delegate = self;
  self.topicTableView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  self.navigationItem.hidesBackButton = NO;
  [[self navigationController] setNavigationBarHidden:NO animated:NO];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
// preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"showPreparingVC"]) {
    QZBProgressViewController *navigationController =
        segue.destinationViewController;
    navigationController.topic = self.choosedTopic;
  }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  return [self.topics count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *identifier = @"topicCell";

  QZBTopicTableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier:identifier];

  QZBGameTopic *topic = (QZBGameTopic *)self.topics[indexPath.row];

  cell.topicName.text = topic.name;

  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  self.choosedTopic = self.topics[indexPath.row];
  NSLog(@"%ld", (long)self.choosedTopic.topic_id);
  [self performSegueWithIdentifier:@"showPreparingVC" sender:nil];
}

#pragma mark - topics init

- (void)initTopicsWithCategory:(QZBCategory *)category {
  NSLog(@"category name:  %@", category.name);

  self.title = category.name;

  [[QZBServerManager sharedManager] getTopicsWithID:category.category_id
      onSuccess:^(NSArray *topics) {
        
        NSLog(@"setted topics");
          self.topics = [NSArray arrayWithArray:topics];
          [self.topicTableView reloadData];
      }
      onFailure:^(NSError *error, NSInteger statusCode) { NSLog(@"fail"); }];
}
@end
