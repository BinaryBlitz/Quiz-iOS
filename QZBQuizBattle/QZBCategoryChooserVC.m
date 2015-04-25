//
//  QZBCategoryChooserVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 15/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBCategoryChooserVC.h"
#import "CoreData+MagicalRecord.h"
#import "QZBServerManager.h"
#import "QZBCategory.h"
#import "QZBCategoryTableViewCell.h"
#import "QZBTopicChooserControllerViewController.h"
#import "QZBCurrentUser.h"
#import "QZBUser.h"
#import "QZBRegistrationChooserVC.h"
#import "UIViewController+QZBControllerCategory.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface QZBCategoryChooserVC ()

@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) QZBCategory *choosedCategory;
@property (strong, nonatomic) id<QZBUserProtocol> user;

@end

@implementation QZBCategoryChooserVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setNeedsStatusBarAppearanceUpdate];

    // delete this line after added new controllers before this one

    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    
     NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                            ascending:YES];
    
    _categories = [NSArray arrayWithArray:[[QZBCategory MR_findAll] sortedArrayUsingDescriptors:@[ sort ]]];
    
   // _categories = [QZBCategory MR_findAll];
    
    [self initStatusbarWithColor:[UIColor blackColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if ([[QZBCurrentUser sharedInstance] checkUser]) {
        [self initCategories];
    }
    
    

    [[self navigationController] setNavigationBarHidden:NO animated:NO];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
// preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showTopicsSegue"]) {
        QZBTopicChooserControllerViewController *destination = segue.destinationViewController;
        if(self.user){
            [destination initWithChallengeUser:self.user category:self.choosedCategory];
        }else{
            [destination initTopicsWithCategory:self.choosedCategory];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.categories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"categoryCell";

    QZBCategoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    QZBCategory *category = self.categories[indexPath.row];
    

    cell.categoryLabel.text = category.name;
    NSURL *categoryBannerURL =
    [NSURL URLWithString:category.banner_url];
    
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:categoryBannerURL
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [cell.categoryImageView  setImageWithURLRequest:imageRequest
                                   placeholderImage:[UIImage imageNamed:@"BG_iPhone_5"]
                                            success:nil
                                            failure:nil];

  //  [cell.categoryImageView setImageWithURL:categoryBannerURL];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.choosedCategory = self.categories[indexPath.row];
    // NSLog(@"%ld", (long)self.choosedCategory.category_id);
     [self performSegueWithIdentifier:@"showTopicsSegue" sender:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[UIScreen mainScreen] bounds].size.width/3.0;
}



#pragma mark - custom init

- (void)initCategories {
    //__weak typeof(self) weakSelf = self;

    [[QZBServerManager sharedManager] getСategoriesOnSuccess:^(NSArray *topics) {

        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                               ascending:YES];
        
        _categories = [NSArray arrayWithArray:[[QZBCategory MR_findAll]
                                               sortedArrayUsingDescriptors:@[ sort ]]];

        [self.mainTableView reloadData];

    } onFailure:^(NSError *error, NSInteger statusCode) {

        if (statusCode == 401) {
            [[QZBCurrentUser sharedInstance] userLogOut];

            // fix it
            [self performSegueWithIdentifier:@"logOutUnauthorized" sender:nil];
        }

    }];
}

-(void)initWithUser:(id<QZBUserProtocol>) user{
    self.user = user;
  //  [self initCategories];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
