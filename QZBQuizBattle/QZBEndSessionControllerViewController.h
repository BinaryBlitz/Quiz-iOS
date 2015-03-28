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
@property (weak, nonatomic) IBOutlet UILabel *firstUserScore;
@property (weak, nonatomic) IBOutlet UILabel *opponentUserScore;

@property (weak, nonatomic) IBOutlet UAProgressView *circularProgress;


@end
