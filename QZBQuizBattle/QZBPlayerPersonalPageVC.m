//
//  QZBPlayerPersonalPageVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 21/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBPlayerPersonalPageVC.h"
#import "QZBCurrentUser.h"
#import "QZBPlayerInfoCell.h"
#import "QZBTopicTableViewCell.h"
#import "QZBFriendsHorizontalCell.h"
#import "UIImageView+AFNetworking.h"

@interface QZBPlayerPersonalPageVC () <UITableViewDataSource,
                                       UITableViewDelegate>

@end

@implementation QZBPlayerPersonalPageVC

- (void)viewDidLoad {
  [super viewDidLoad];

  self.playerTableView.delegate = self;
  self.playerTableView.dataSource = self;
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userPressShowAllButton:) name:@"QZBUserPressShowAllButton" object:nil];

  // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animate {
  [super viewWillAppear:animate];

  self.title = [QZBCurrentUser sharedInstance].user.name;
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *playerIdentifier = @"playerСell";
  NSString *friendsIdentifier = @"friendsCell";

  UITableViewCell *cell;

  if (indexPath.row == 0) {
    QZBPlayerInfoCell *playerCell = (QZBPlayerInfoCell *)
        [tableView dequeueReusableCellWithIdentifier:playerIdentifier];

    NSURL *picUrl =
        [NSURL URLWithString:
                   @"https://pp.vk.me/c608721/v608721290/27cd/SV28DOJ177Q.jpg"];

    [playerCell.playerUserpic setImageWithURL:picUrl];

    cell = playerCell;
  } else if (indexPath.row == 1 || indexPath.row == 2) {
    QZBFriendsHorizontalCell *friendsCell =
        [tableView dequeueReusableCellWithIdentifier:friendsIdentifier];
    return friendsCell;
   // cell = friendsCell;
  }else if(indexPath.row == 3){
    cell = [tableView dequeueReusableCellWithIdentifier:@"mostLovedTopics"];
    
    return cell;
  } else if(indexPath.row>3){
    QZBTopicTableViewCell *topicCell =
    [tableView dequeueReusableCellWithIdentifier:@"topicCell"];
    topicCell.topicName.text = [NSString stringWithFormat:@"топик %ld", indexPath.row];
    return topicCell;
   // cell = topicCell;
    
  }
  return cell;
}


-(void)userPressShowAllButton:(NSNotification *)notification{
  
  NSLog(@"%@",notification.object);
  
  NSIndexPath *indexPath = (NSIndexPath *)notification.object;
  
  if(indexPath.row == 1){
    [self performSegueWithIdentifier:@"showFriendsList" sender:nil];
  } else if (indexPath.row == 2){
    [self performSegueWithIdentifier:@"showAchivements" sender:nil];
  }
  
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
  
  if(indexPath.row<3){
    return 127.0f;
  }else if(indexPath.row == 3){
    return 47.0f;
  }
    else{
    return 61.0f;
  }
  
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)dissmisVC:(id)sender {
  
  [self dismissViewControllerAnimated:YES completion:nil];
  
}




@end
