//
//  QZBCreateRoomController.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 29/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBCreateRoomController.h"

//model
#import "QZBServerManager.h"
#import "QZBGameTopic.h"

//cells
#import "QZBTopicTableViewCell.h"
#import "QZBPlayerCountChooserCell.h"

//cell identifiers

NSString *const QZBPlayerCountChooserCellIdentifier = @"playerCountChooserCell";
NSString *const QZBChooseTopicCellIdentifier = @"chooseTopicCellIdentifier";
NSString *const QZBTopicCellIdentifier = @"topicCell";
NSString *const QZBChooseTopicDescriptionCellIdentifier = @"chooseTopicDescriptionCellIdentifier";

NSString *const QZBPasswordOnlyChooserCellIdentifier = @"passwordOnlyChooserCellIdentifier";


//cell heigths

const CGFloat playersCountCellHeight = 132.0;
const CGFloat topicChooserDescriptionCellHeight = 65.0;

const CGFloat topicCellHeight = 79.0;

//segues

NSString *const QZBShowRoomCategoryChooserFromCreate = @"showRoomCategoryChooser";

@interface QZBCreateRoomController()

@property(strong, nonatomic) QZBGameTopic *topic;

@end

@implementation QZBCreateRoomController


-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.title = @"Создание комнаты";
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row == 0){
        QZBPlayerCountChooserCell *cell = [tableView dequeueReusableCellWithIdentifier:QZBPlayerCountChooserCellIdentifier];
        return cell;
    }else if(indexPath.row == 1){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:QZBChooseTopicDescriptionCellIdentifier];
        
        return cell;
        
        
    }else if(indexPath.row == 2){
        if(self.topic){
            QZBTopicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:QZBTopicCellIdentifier];
            
            [cell initWithTopic:self.topic];
            
            return cell;
        }else{
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:QZBChooseTopicCellIdentifier];
            
            return cell;
        }
    }
    else
    {
        return nil;
    }
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row == 0 ){
        return playersCountCellHeight;
    }else if(indexPath.row == 1){
        return topicChooserDescriptionCellHeight;
    } else if(indexPath.row == 2){
        return topicCellHeight;
    }
    
    else{
        return 42;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if([cell.reuseIdentifier isEqualToString:QZBChooseTopicCellIdentifier]){
        //do segue to group chooser
        
        [self performSegueWithIdentifier:QZBShowRoomCategoryChooserFromCreate sender:nil];
    }
    
}

#pragma mark - setting topic

-(void)setUserTopic:(QZBGameTopic *)topic{
    self.topic = topic;
    
    [[QZBServerManager sharedManager] POSTCreateRoomWithTopic:topic private:YES OnSuccess:^(QZBRoom *room) {
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
    }];
    [self.tableView reloadData];
}

@end
