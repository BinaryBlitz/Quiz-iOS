//
//  QZBImageViewerVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 10/07/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBImageViewerVC.h"
#import <UIImageView+AFNetworking.h>
#import "QZBCurrentUser.h"

@interface QZBImageViewerVC()

@property(strong, nonatomic) id<QZBUserProtocol> user;

@end

@implementation QZBImageViewerVC

-(void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(self.user.imageURL){
        
        [self.userPicImageView setImageWithURL:self.user.imageURL
                              placeholderImage:[UIImage imageNamed:@"userpicStandart"]];
    } else {
        [self.userPicImageView setImage:[UIImage imageNamed:@"userpicStandart"]];
    }

}

-(void)configureWithUser:(id<QZBUserProtocol>)user {
    
    self.user = user;
    
//    if(user.imageURL){
//        
//        [self.userPicImageView setImageWithURL:user.imageURL
//                              placeholderImage:[UIImage imageNamed:@"userpicStandart"]];
//    } else {
//        [self.userPicImageView setImage:[UIImage imageNamed:@"userpicStandart"]];
//    }
//    
    
    if([[QZBCurrentUser sharedInstance].user.userID isEqualToNumber:user.userID]){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                                       initWithTitle:@"Изменить"
                                                                       style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(showChoose)];
        
    }
}

-(void)showChoose{
    
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
