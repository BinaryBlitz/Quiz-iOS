//
//  ViewController.h
//  QZBQuizBattle
//
//  Контроллер управления сессией
//
//  Created by Andrey Mikhaylov on 11/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UAProgressView.h"

@class QZBSession;
@class DFImageView;
//@class UACircularProgressView;

@interface QZBGameSessionViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *qestionLabel;
@property (weak, nonatomic) IBOutlet DFImageView *questionImageView;
//@property (weak, nonatomic) IBOutlet UIImageView *questionImageView;
@property (weak, nonatomic) IBOutlet UIView *questBackground;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *answerButtons;
@property (weak, nonatomic) IBOutlet UILabel *firstUserScore;
@property (weak, nonatomic) IBOutlet UILabel *opponentScore;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UILabel *roundLabel;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *opponentNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UIImageView *opponentImage;
//@property (weak, nonatomic) IBOutlet UIView *opponentScoreView;

@property (weak, nonatomic) IBOutlet UAProgressView *progressView;

//@property (weak, nonatomic) IBOutlet UACircularProgressView *circularProgress;

//@property (strong, nonatomic) QZBSession *session;

@end
