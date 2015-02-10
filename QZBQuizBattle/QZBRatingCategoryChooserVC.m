//
//  QZBRatingCategoryChooserVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 10/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRatingCategoryChooserVC.h"
#import "QZBRatingMainVC.h"

@interface QZBRatingCategoryChooserVC ()

@end

@implementation QZBRatingCategoryChooserVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [super tableView:tableView numberOfRowsInSection:section]+1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row == 0){
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        cell.textLabel.text = @"все темы";
        return cell;
    }else{
        NSIndexPath *ip =[NSIndexPath indexPathForRow:indexPath.row-1
                                            inSection:indexPath.section];
        return [super tableView:tableView cellForRowAtIndexPath:ip];
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0){
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if ([[self.navigationController.viewControllers firstObject] isKindOfClass:[QZBRatingMainVC class]]) {
            NSLog(@"YES");
            QZBRatingMainVC *mainVC = (QZBRatingMainVC *)[self.navigationController.viewControllers firstObject];
            mainVC.category = nil;
            mainVC.topic = nil;
            
            
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        }
    }else{
        NSIndexPath *ip = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.row];
        [super tableView:tableView didSelectRowAtIndexPath:ip];
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
