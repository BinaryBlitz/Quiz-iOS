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


@interface QZBTopicChooserControllerViewController ()<UITableViewDataSource, UITableViewDelegate>

@property(strong, nonatomic) NSArray *topics;
@property(strong, nonatomic) QZBGameTopic *choosedTopic;

@end

@implementation QZBTopicChooserControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
  //NSDictionary *dict = @{@"name":@"CS"};
  //QZBGameTopic *topic = [[QZBGameTopic alloc] initWithDictionary:dict];
  
  [self initTopics];
  
  //self.topics = [NSArray arrayWithObject:topic];
  
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
  
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  
  
  if ([segue.identifier isEqualToString:@"showPreparingVC"]) {
    
    QZBProgressViewController *navigationController =
    segue.destinationViewController;
    navigationController.topic = self.choosedTopic;

  }
  
  }


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  
  return [self.topics count];
  
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  
  NSString *identifier = @"topicCell";
  
  QZBTopicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                                  identifier];
  
  QZBGameTopic *topic = (QZBGameTopic *)self.topics[indexPath.row];
  
  cell.topicName.text = topic.name;
  
  return cell;
  
}


#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  self.choosedTopic = self.topics[indexPath.row];
  NSLog(@"%ld", (long)self.choosedTopic.topic_id);
  [self performSegueWithIdentifier:@"showPreparingVC" sender:nil];
}

#pragma mark - topics init

-(void)initTopics{
  
  [[QZBServerManager sharedManager] getTopicsWithID:1 onSuccess:^(NSArray *topics) {
    self.topics = [NSArray arrayWithArray:topics];
    [self.topicTableView reloadData];
  } onFailure:^(NSError *error, NSInteger statusCode) {
    NSLog(@"fail");
  }];
  
  
}
@end
