//
//  QZBRoomResultTVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 25/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRoomResultTVC.h"
#import "QZBRoomUserResultCell.h"
#import "QZBUserWithTopic.h"
#import "QZBRoom.h"


//cell identifiers
NSString *const QZBRoomUserResultCellIdentifier = @"roomUserResultCellIdentifier";

@interface QZBRoomResultTVC()

@property(strong, nonatomic) NSMutableArray *usersInResult;
@property(strong, nonatomic) QZBRoom *room;


@end

@implementation QZBRoomResultTVC


-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.title = @"Результаты";
}

- (void)configureResultWithRoom:(QZBRoom *)room {
    self.room = room;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.usersInResult.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    QZBRoomUserResultCell *cell = [tableView dequeueReusableCellWithIdentifier:QZBRoomUserResultCellIdentifier];
    
    QZBUserWithTopic *userWithTopic = self.usersInResult[indexPath.row];
    
    NSInteger position = indexPath.row + 1;
    
    
    [cell confirureWithUserWithTopic:userWithTopic position:@(position)];
    
    return cell;
    
    
}

#pragma mark - UITableViewDelegate
@end
