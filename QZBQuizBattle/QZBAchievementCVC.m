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
#import "QZBAchievementManager.h"
#import "GPUImage.h"

@interface QZBAchievementCVC () <UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) NSArray *achivArray;
@property (assign, nonatomic) float cornerRadius;
//@property (strong, nonatomic) SCLAlertView *alert;

@end

@implementation QZBAchievementCVC

static NSString *const reuseIdentifier = @"achievementIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    self.title = @"Достижения";

    CGRect rect = [UIScreen mainScreen].bounds;

    CGFloat width = (CGRectGetWidth(rect) / 3.0) - 10;

    self.cornerRadius = width / 2.0;

    //  [self initAchivs];

    self.achivTableView.dataSource = self;
    self.achivTableView.delegate = self;

    //    [[QZBServerManager sharedManager] GETachievementsForUserID:@(1)
    //        onSuccess:^(NSArray *achievements) {
    //
    //        }
    //        onFailure:^(NSError *error, NSInteger statusCode){
    //
    //        }];
    //
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

#pragma mark - custom init

- (void)initAchievmentsWithGettedAchievements:(NSArray *)achievs {
    self.achivArray = [[QZBAchievementManager sharedInstance] mergeAchievemtsWithGetted:achievs];

    [self.collectionView reloadData];
}

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

  //  UIImage *image = nil;

    cell.achievementPic.layer.cornerRadius = self.cornerRadius;
    cell.achievementPic.layer.masksToBounds = YES;
    if (achiv.isAchieved) {
        // image = [UIImage imageNamed:@"achiv"];
        
        if(achiv.imageURL){
            [cell.achievementPic setImageWithURL:achiv.imageURL];
        }else{
            [cell.achievementPic setImage:[UIImage imageNamed:@"achiv"]];
        }
    } else {
        NSURLRequest *imageRequest =
            [NSURLRequest requestWithURL:achiv.imageURL
                             cachePolicy:NSURLRequestReturnCacheDataElseLoad
                         timeoutInterval:60];

        [cell.achievementPic setImageWithURLRequest:imageRequest
                                   placeholderImage:[UIImage imageNamed:@"notAchiv"]
                                            success:^(NSURLRequest *request,
                                                      NSHTTPURLResponse *response, UIImage *image) {

                                                cell.achievementPic.image =
                                                    [self grayscaleImagefromImage:image];

                                            }
                                            failure:nil];
    }

    cell.achievementTitle.text = achiv.name;

    return cell;
}

- (UIImage *)grayscaleImagefromImage:(UIImage *)image {
    UIGraphicsBeginImageContextWithOptions(image.size, YES, 1.0);
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    // Draw the image with the luminosity blend mode.
    [image drawInRect:imageRect blendMode:kCGBlendModeLuminosity alpha:1.0];
    // Get the resulting image.
    UIImage *filteredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return filteredImage;
}

- (void)initAchivs {
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

    QZBAchievementCollectionCell *cell =
        (QZBAchievementCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];

    UIImage *img = cell.achievementPic.image;

    [alert showCustom:self
                   image:img
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

- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGRect rect = [UIScreen mainScreen].bounds;

    CGFloat width = (CGRectGetWidth(rect) / 3.0) - 10;

    return CGSizeMake(width, width * 1.5);
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
