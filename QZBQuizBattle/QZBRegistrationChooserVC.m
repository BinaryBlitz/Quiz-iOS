//
//  QZBRegistrationChooserVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 16/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRegistrationChooserVC.h"
#import "QZBCurrentUser.h"

@interface QZBRegistrationChooserVC ()

@end

@implementation QZBRegistrationChooserVC

- (void)viewDidLoad {
    [super viewDidLoad]; /*
   if([[QZBCurrentUser sharedInstance] checkUser]){

     NSLog(@"exist");
     [self performSegueWithIdentifier:@"userExist" sender:nil];

   }*/

    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([[QZBCurrentUser sharedInstance] checkUser]) {
        NSLog(@"exist");
        [self performSegueWithIdentifier:@"userExist" sender:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

//  NSLog(@"%@",segue);
}*/

@end
