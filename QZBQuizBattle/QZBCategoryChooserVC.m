//
//  QZBCategoryChooserVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 15/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBCategoryChooserVC.h"
#import "QZBServerManager.h"
#import "QZBCategory.h"
#import "QZBCategoryTableViewCell.h"
#import "QZBTopicChooserControllerViewController.h"
#import "QZBCurrentUser.h"
#import "QZBRegistrationChooserVC.h"


@interface QZBCategoryChooserVC ()<UITableViewDataSource, UITableViewDelegate>
@property(strong, nonatomic) NSArray *categories;
@property(strong, nonatomic) QZBCategory *choosedCategory;

@end

@implementation QZBCategoryChooserVC

- (void)viewDidLoad {
    [super viewDidLoad];
  
     //delete this line after added new controllers before this one
  
  self.mainTableView.delegate = self;
  self.mainTableView.dataSource = self;
  [self initCategories];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
 // self.navigationItem.hidesBackButton = YES;
  [[self navigationController] setNavigationBarHidden:NO animated:NO];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
  if ([segue.identifier isEqualToString:@"showTopicsSegue"]) {
    
    QZBTopicChooserControllerViewController *destination =
    segue.destinationViewController;
    [destination initTopicsWithCategory:self.choosedCategory];
    
  }
  
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  return [self.categories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  
  NSString *identifier = @"categoryCell";
  
  QZBCategoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
  
  QZBCategory *category =
  self.categories[indexPath.row];
  
  cell.categoryLabel.text = category.name;
  
  return cell;
}


#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  self.choosedCategory = self.categories[indexPath.row];
 //NSLog(@"%ld", (long)self.choosedCategory.category_id);
  [self performSegueWithIdentifier:@"showTopicsSegue" sender:nil];
}


-(void)initCategories{
  
  __weak typeof(self) weakSelf = self;
  
  [[QZBServerManager sharedManager] getСategoriesOnSuccess:^(NSArray *topics) {
    weakSelf.categories = topics;
    [self.mainTableView reloadData];
  } onFailure:^(NSError *error, NSInteger statusCode) {
    
  }];
  
  
}

#pragma mark - actions
- (IBAction)logOutAction:(id)sender {
  
  [[QZBCurrentUser sharedInstance] userLogOut];
  
  UIViewController *destinationVC;
  
  NSArray *controllers = self.navigationController.viewControllers;
  
  for(UIViewController *controller in controllers){
    if([controller isKindOfClass:[QZBRegistrationChooserVC class]]){
      destinationVC = controller;
      break;
    }
    
  }
  
  [self.navigationController popToViewController:destinationVC animated:YES];
  
}




@end
