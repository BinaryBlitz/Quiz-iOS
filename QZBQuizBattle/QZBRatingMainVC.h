//
//  QZBRatingMainVC.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 07/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QZBCategory;
@class QZBGameTopic;

@interface QZBRatingMainVC : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *chooseTopicButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightButton;
@property (strong, nonatomic) QZBCategory *category;
@property (strong, nonatomic) QZBGameTopic *topic;

@end
