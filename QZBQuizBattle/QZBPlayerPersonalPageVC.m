//
//  QZBPlayerPersonalPageVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 21/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBPlayerPersonalPageVC.h"
#import "QZBCurrentUser.h"
#import "QZBPlayerInfoCell.h"
#import "QZBTopicTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "QZBFriendHorizontalCell.h"
#import "QZBAchivHorizontalCell.h"
#import "QZBAchievement.h"

@interface QZBPlayerPersonalPageVC () <UITableViewDataSource, UITableViewDelegate>

@property(strong, nonatomic)NSArray *achivArray;

@end

@implementation QZBPlayerPersonalPageVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initAchivs];
    
    self.playerTableView.delegate = self;
    self.playerTableView.dataSource = self;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userPressShowAllButton:)
                                                 name:@"QZBUserPressShowAllButton"
                                               object:nil];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animate {
    [super viewWillAppear:animate];

    self.navigationItem.title = [QZBCurrentUser sharedInstance].user.name;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   static NSString *playerIdentifier = @"playerСell";
   static NSString *friendsIdentifier = @"friendsCell";
    static NSString *achivIdentifier = @"achivCell";

    UITableViewCell *cell;

    if (indexPath.row == 0) {
        QZBPlayerInfoCell *playerCell =
            (QZBPlayerInfoCell *)[tableView dequeueReusableCellWithIdentifier:playerIdentifier];

        NSURL *picUrl = [NSURL URLWithString:@"https://pp.vk.me/c608721/v608721290/27cd/SV28DOJ177Q.jpg"];

        [playerCell.playerUserpic setImageWithURL:picUrl];

        cell = playerCell;
    } else if (indexPath.row == 1 ) {
        QZBFriendHorizontalCell *friendsCell = [tableView dequeueReusableCellWithIdentifier:friendsIdentifier];
        return friendsCell;
        // cell = friendsCell;
    } else if(indexPath.row == 2){
        QZBAchivHorizontalCell *achivCell = [tableView dequeueReusableCellWithIdentifier:achivIdentifier];
        
        [achivCell setAchivArray:self.achivArray];
        achivCell.buttonTitle = @"Показать\n все";
        return achivCell;
    }
    else if (indexPath.row == 3) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"mostLovedTopics"];

        return cell;
    } else if (indexPath.row > 3) {
        QZBTopicTableViewCell *topicCell = [tableView dequeueReusableCellWithIdentifier:@"topicCell"];
        topicCell.topicName.text = [NSString stringWithFormat:@"топик %ld", (long)indexPath.row];
        return topicCell;
        // cell = topicCell;
    }
    return cell;
}

- (void)userPressShowAllButton:(NSNotification *)notification {
    NSLog(@"%@", notification.object);

    NSIndexPath *indexPath = (NSIndexPath *)notification.object;

    if (indexPath.row == 1) {
        [self performSegueWithIdentifier:@"showFriendsList" sender:nil];
    } else if (indexPath.row == 2) {
        [self performSegueWithIdentifier:@"showAchivements" sender:nil];
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 3) {
        return 127.0f;
    } else if (indexPath.row == 3) {
        return 47.0f;
    } else {
        return 61.0f;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - actions
- (IBAction)showAchivements:(UIButton *)sender {
    
    [self performSegueWithIdentifier:@"showAchivements" sender:nil];
}

- (IBAction)logOutAction:(UIBarButtonItem *)sender {
    [[QZBCurrentUser sharedInstance] userLogOut];

    [self performSegueWithIdentifier:@"showRegistrationScreenFromUserScreen" sender:nil];
}


#pragma mark - init friends and achivs

-(void)initAchivs{
    
    [UIImage imageNamed:@"achiv"];
    [UIImage imageNamed:@"notAchiv"];
    
    self.achivArray = @[[[QZBAchievement alloc] initWithName:@"achiv"
                                                   imageName:@"achiv"],
                        [[QZBAchievement alloc] initWithName:@"notAchiv"
                                                   imageName:@"notAchiv"],
                        [[QZBAchievement alloc] initWithName:@"achiv2"
                                                   imageName:@"achiv"],
                        [[QZBAchievement alloc] initWithName:@"notAchiv2"
                                                   imageName:@"notAchiv"],
                        [[QZBAchievement alloc] initWithName:@"achiv"
                                                   imageName:@"achiv"],
                        [[QZBAchievement alloc] initWithName:@"notAchiv"
                                                   imageName:@"notAchiv"],
                        [[QZBAchievement alloc] initWithName:@"achiv2"
                                                   imageName:@"achiv"],
                        [[QZBAchievement alloc] initWithName:@"notAchiv2"
                                                   imageName:@"notAchiv"]
                        ];
    
}

@end
