//
//  QZBEndSessionControllerViewController.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 21/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UAProgressView;

@interface QZBEndSessionControllerViewController : UIViewController

@property (weak, nonatomic) IBOutlet UAProgressView *circularProgress;
@property (weak, nonatomic) IBOutlet UAProgressView *circularOldProgress;

@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UIImageView *opponentImage;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *opponentNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *firstUserScore;
@property (weak, nonatomic) IBOutlet UILabel *opponentScore;

@property (weak, nonatomic) IBOutlet UILabel *resultOfSessionLabel;

@property (weak, nonatomic) IBOutlet UILabel *resultScoreLabel;


@end
