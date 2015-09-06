//
//  QZBFriendsRequestsTVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 10/03/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBFriendsRequestsTVC.h"
#import "QZBServerManager.h"
#import "QZBFriendRequestManager.h"
#import "QZBFriendRequest.h"
#import "UIViewController+QZBControllerCategory.h"
#import "QZBFriendRequestCell.h"
#import <TSMessage.h>

@interface QZBFriendsRequestsTVC ()

@end

@implementation QZBFriendsRequestsTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Заявки в друзья";
    

    
    self.tableView.tableFooterView = [self viewForTableViewFooter];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setFriendsOwner:nil
               andFriends:[QZBFriendRequestManager sharedInstance].incoming];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
//    UITabBarController *tabController = self.tabBarController;
//    UITabBarItem *tabbarItem = tabController.tabBar.items[1];
    

    
    //tabbarItem.badgeValue = nil;
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
//    [[QZBServerManager sharedManager] PATCHMarkRequestsAsViewedOnSuccess:^{
//        
//    } onFailure:^(NSError *error, NSInteger statusCode) {
//        
//    }];
}
- (IBAction)acceptFriendRequestAction:(UIButton *)sender {
    
    UITableViewCell *cell = [self parentCellForView:sender];
    
    if(cell){
        if([cell isKindOfClass:[QZBFriendRequestCell class]]){
            
            
            NSLog(@"YES");
            QZBFriendRequestCell *c = (QZBFriendRequestCell *)cell;
            
            [[QZBFriendRequestManager sharedInstance] acceptForUser:c.user callback:^(BOOL succes) {
                if(succes){
                    [TSMessage showNotificationInViewController:self
                                                          title:@"Заявка принята"
                                                       subtitle:@""
                                                           type:TSMessageNotificationTypeSuccess
                                                       duration:1];
                  
                    c.acceptButton.enabled = NO;
                    c.declineButton.enabled = YES;
                    [c.acceptButton setTitle:@"Принято"
                                    forState:UIControlStateDisabled];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"QZBFriendRequestUpdated"
                                                                        object:nil];
                   
                } else {
                    [TSMessage showNotificationWithTitle:QZBNoInternetConnectionMessage
                                                subtitle:nil
                                                    type:TSMessageNotificationTypeError];
                }
            }];
        }
    }
}

- (IBAction)declineFriendRequestAction:(UIButton *)sender {
    UITableViewCell *cell = [self parentCellForView:sender];
    
    if(cell){
        if([cell isKindOfClass:[QZBFriendRequestCell class]]){
            NSLog(@"YES");
            QZBFriendRequestCell *c = (QZBFriendRequestCell *)cell;
            
            [[QZBFriendRequestManager sharedInstance] declineForUser:c.user callback:^(BOOL succes) {
                if(succes){
                    
                    [TSMessage showNotificationInViewController:self
                                                          title:@"Заявка отклонена"
                                                       subtitle:@""
                                                           type:TSMessageNotificationTypeSuccess
                                                       duration:1];
                    
                    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                    });
                    
                    NSIndexPath *ip = [self.tableView indexPathForCell:cell];
                    [self.tableView beginUpdates];
                    
                    [self.tableView deleteRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationRight];
                    
                    [self.tableView endUpdates];
                    
                    [self setFriendsOwner:nil andFriends:[QZBFriendRequestManager sharedInstance].incoming];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"QZBFriendRequestUpdated"
                                                                        object:nil];
                    
                } else {
                    [TSMessage showNotificationWithTitle:QZBNoInternetConnectionMessage
                                                subtitle:nil
                                                    type:TSMessageNotificationTypeError];

                }
            }];
        }
    }

    
}


#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 109.0;
}

#pragma mark - custom view init


-(UIView *)viewForTableViewFooter{
    CGRect r = [UIScreen mainScreen].bounds;
    CGRect destRect = CGRectMake(1, 0, CGRectGetWidth(r), 300);
    UIView *v = [[UIView alloc] initWithFrame:destRect];
    v.backgroundColor = [UIColor whiteColor];
    return v;
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
