//
//  QZBFriendsRequestsTVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 10/03/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBFriendsRequestsTVC.h"
#import "QZBServerManager.h"

@interface QZBFriendsRequestsTVC ()

@end

@implementation QZBFriendsRequestsTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Заявки в друзья";
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[QZBServerManager sharedManager] PATCHMarkRequestsAsViewedOnSuccess:^{
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
    }];
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
