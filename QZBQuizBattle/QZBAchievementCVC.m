//
//  QZBAchievementCVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 11/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBAchievementCVC.h"
#import "QZBAchievementCollectionCell.h"
#import "UIImageView+AFNetworking.h"
#import "QZBAchievement.h"
#import "QZBServerManager.h"
#import <SCLAlertView-Objective-C/SCLAlertView.h>
#import "UIColor+QZBProjectColors.h"

@interface QZBAchievementCVC ()

@property (strong, nonatomic) NSArray *achivArray;
//@property (strong, nonatomic) SCLAlertView *alert;

@end

@implementation QZBAchievementCVC

static NSString *const reuseIdentifier = @"achievementIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    self.title = @"Достижения";


    [self initAchivs];

    self.achivTableView.dataSource = self;
    self.achivTableView.delegate = self;

    [[QZBServerManager sharedManager] GETachievementsForUserID:@(1)
        onSuccess:^(NSArray *achievements) {

        }
        onFailure:^(NSError *error, NSInteger statusCode){

        }];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before
navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    //#warning Incomplete method implementation -- Return the number of items in the section
    return [self.achivArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QZBAchievementCollectionCell *cell =
        [self.achivTableView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];

    QZBAchievement *achiv = self.achivArray[indexPath.row];

    [cell.achievementPic setImage:[UIImage imageNamed:@"notAchiv"]];
    cell.achievementTitle.text = achiv.name;
    ;

    // Configure the cell

    NSLog(@"%ld", (long)indexPath.row);

    return cell;
}

- (void)initAchivs {
    [UIImage imageNamed:@"achiv"];
    [UIImage imageNamed:@"notAchiv"];

    [[QZBServerManager sharedManager] GETachievementsForUserID:0
        onSuccess:^(NSArray *achievements) {
            self.achivArray = achievements;
            [self.collectionView reloadData];
        }
        onFailure:^(NSError *error, NSInteger statusCode){

        }];
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    QZBAchievement *achievment = self.achivArray[indexPath.row];
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.backgroundType = Blur;
    alert.showAnimationType = FadeIn;

 
    [alert showCustom:self
                   image:[UIImage imageNamed:@"achiv"]
                   color:[UIColor lightBlueColor]
                   title:achievment.name
                subTitle:achievment.achievementDescription
        closeButtonTitle:@"ОК"
                duration:0.0f];
}

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView
shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
        return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath
*)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item,
and react to actions
performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView
shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
        return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action
forItemAtIndexPath:(NSIndexPath
*)indexPath withSender:(id)sender {
        return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action
forItemAtIndexPath:(NSIndexPath
*)indexPath withSender:(id)sender {

}
*/

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


@end
