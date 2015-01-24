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
#import "QZBFriendsHorizontalCell.h"
#import "UIImageView+AFNetworking.h"

@interface QZBPlayerPersonalPageVC ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation QZBPlayerPersonalPageVC

- (void)viewDidLoad {
    [super viewDidLoad];
  
  self.playerTableView.delegate = self;
  self.playerTableView.dataSource = self;
  
 
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animate{
  [super viewWillAppear:animate];
  
  self.title = [QZBCurrentUser sharedInstance].user.name;
  
}

#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  
  NSString *playerIdentifier = @"playerСell";
  NSString *friendsIdentifier = @"friendsCell";
  
  UITableViewCell *cell;
  
  
  if(indexPath.row == 0){
    QZBPlayerInfoCell *playerCell = (QZBPlayerInfoCell *)[tableView
                                 dequeueReusableCellWithIdentifier:playerIdentifier];
    
    NSURL *picUrl = [NSURL URLWithString:@"https://pp.vk.me/c608721/v608721290/27cd/SV28DOJ177Q.jpg"];
    
    [playerCell.playerUserpic setImageWithURL:picUrl];
    
    cell = playerCell;
  }else if (indexPath.row == 1){
    QZBFriendsHorizontalCell *friendsCell = [tableView dequeueReusableCellWithIdentifier:friendsIdentifier];
    
    cell = friendsCell;
    
  }
  return cell;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
