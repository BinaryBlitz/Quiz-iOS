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
#import "UIViewController+QZBControllerCategory.h"
#import "UIColor+QZBProjectColors.h"
#import "QZBTopicTableViewCell.h"
#import "QZBDescriptionCell.h"//mainDescriptionCell

@implementation QZBMainGameScreenTVC

-(void)viewDidLoad{
    [super viewDidLoad];
    
  
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.title = @"iQuiz";//REDO
    
    [self initStatusbarWithColor:[UIColor blackColor]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 13;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row == 0){
    
    QZBMainChallengesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mainChallengeCell"];
        return cell;
    }else{
        UIColor *color = nil;
        NSString *text = nil;
        
        if(indexPath.row>=1 && indexPath.row<=4){
            color = [UIColor lightRedColor];
            text = @"Новинки";
            
        }else if(indexPath.row>=5 && indexPath.row<=8){
            color = [UIColor lightBlueColor];
            text = @"Популярное у друзей";
        } else if(indexPath.row>=9 && indexPath.row<=12){
            color = [UIColor lightGreenColor];
            text = @"Любимые темы";
        } else{
            color = [UIColor whiteColor];
        }

        
        
        if(indexPath.row == 1 || indexPath.row == 5 || indexPath.row == 9){
            QZBDescriptionCell *descrCell = [tableView dequeueReusableCellWithIdentifier:@"mainDescriptionCell"];
            
            
            
            descrCell.categoryDescriptionLabel.text = text;
            descrCell.backgroundColor = color;
        
            return descrCell;
            
        }
        
        QZBTopicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"topicCell"];
        
        cell.backgroundColor = color;
        
        cell.topicName.text = @"my topic name";
        return cell;
    }
   
}





#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if([cell.reuseIdentifier isEqualToString:@"mainChallengeCell"]){
        [self performSegueWithIdentifier:@"showChallenges" sender:nil];
    }else if([cell.reuseIdentifier isEqualToString:@"mainDescriptionCell"]){
        return;
        
    }
        else{
        
        //NSIndexPath *newIP = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0];
        
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#(NSString *)#>
    
    if(indexPath.row == 1 || indexPath.row == 5 || indexPath.row == 9){
        return 44.0;
        
    }else{
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 2){
        tableView.backgroundColor = [UIColor whiteColor];
        
    }
    if(indexPath.row == 12){
        tableView.backgroundColor = [UIColor lightGreenColor];
    }
    
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}



@end
