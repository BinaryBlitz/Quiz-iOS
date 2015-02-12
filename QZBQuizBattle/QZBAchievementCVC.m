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

@interface QZBAchievementCVC ()

@end

@implementation QZBAchievementCVC

static NSString *const reuseIdentifier = @"achievementIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];

    self.achivTableView.dataSource = self;
    self.achivTableView.delegate = self;
    

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //#warning Incomplete method implementation -- Return the number of items in the section
    return 20;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QZBAchievementCollectionCell *cell =
        [self.achivTableView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];

    // NSURL *url = [NSURL URLWithString:@"https://pp.vk.me/c624622/v624622532/14797/nkV5EYb57S4.jpg"];
    UIImage *img = nil;
    if (indexPath.row % 5 == 0) {
        img = [UIImage imageNamed:@"achiv"];
    } else {
        img = [UIImage imageNamed:@"notAchiv"];
    }
    [cell.achievementPic setImage:img];
    cell.achievementTitle.text = [NSString stringWithFormat:@"achiv %ld", (long)indexPath.row];

    // Configure the cell

    NSLog(@"%ld", (long)indexPath.row);

    return cell;
}


#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
        return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions
performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
        return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath
*)indexPath withSender:(id)sender {
        return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath
*)indexPath withSender:(id)sender {

}
*/

@end
