//
//  QZBMainGameScreenTVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 18/03/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBMainGameScreenTVC.h"
#import "QZBServerManager.h"
#import "QZBMainChallengesCell.h"

@implementation QZBMainGameScreenTVC

-(void)viewDidLoad{
    [super viewDidLoad];
    
  
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    QZBMainChallengesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mainChallengeCell"];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if([cell.reuseIdentifier isEqualToString:@"mainChallengeCell"]){
        [self performSegueWithIdentifier:@"showChallenges" sender:nil];
    }
}

@end
