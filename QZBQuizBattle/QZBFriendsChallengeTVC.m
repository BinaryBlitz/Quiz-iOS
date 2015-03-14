//
//  QZBFriendsChallengeTVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 13/03/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBFriendsChallengeTVC.h"
#import "QZBGameTopic.h"
#import "QZBProgressViewController.h"


@interface QZBFriendsChallengeTVC ()

@property (strong, nonatomic) QZBGameTopic *topic;

@end

@implementation QZBFriendsChallengeTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self performSegueWithIdentifier:@"startChallengeSegue" sender:nil];
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"startChallengeSegue"]){
        
        QZBProgressViewController *destinationVC = segue.destinationViewController;
        destinationVC.topic = self.topic;
        
    }
    
}

#pragma mark - custom init

-(void)setFriendsOwner:(id<QZBUserProtocol>)user andFriends:(NSArray *)friends gameTopic:(QZBGameTopic *)topic{
    self.topic = topic;
    [super setFriendsOwner:user andFriends:friends];
}

@end
