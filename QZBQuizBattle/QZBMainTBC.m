//
//  QZBMainTBC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 30/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBMainTBC.h"
#import "QZBCurrentUser.h"

@interface QZBMainTBC ()

@end

@implementation QZBMainTBC

- (void)viewDidLoad {
    [super viewDidLoad];

    [[QZBCurrentUser sharedInstance] checkUser];
    
    self.tabBar.tintColor = [UIColor whiteColor];
    self.tabBar.barTintColor = [UIColor blackColor];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (![[QZBCurrentUser sharedInstance] checkUser]) {
        NSLog(@"exist");
        [self performSegueWithIdentifier:@"showRegistrationScreen" sender:nil];
    }
    
    
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
