//
//  QZBRatingMainVC.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 07/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QZBUserProtocol.h"

@class QZBCategory;
@class QZBGameTopic;

@interface QZBRatingMainVC : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *chooseTopicButton;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UIView *buttonsBackgroundView;
@property (strong, nonatomic) UIView *buttonBackgroundView;

@property (strong, nonatomic) QZBCategory *category;
@property (strong, nonatomic) QZBGameTopic *topic;

-(void)showUserPage:(id<QZBUserProtocol>)user;
-(void)initWithTopic:(QZBGameTopic *)topic;

-(void)createButtonBackgroundView;

@end
