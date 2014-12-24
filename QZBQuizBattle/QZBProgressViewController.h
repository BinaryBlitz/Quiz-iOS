//
//  QZBProgressViewController.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 13/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QZBGameTopic;
@interface QZBProgressViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (strong, nonatomic) NSTimer *myTimer;
@property(strong, nonatomic) QZBGameTopic *topic;

@end
