//
//  QZBProgressViewController.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 13/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QZBUserProtocol.h"
@class QZBGameTopic;
@class QZBSession;

@interface QZBProgressViewController : UIViewController
@property (strong, nonatomic) QZBGameTopic *topic;

//@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelCrossButton;
@property (weak, nonatomic) IBOutlet UILabel *topicLabel;
@property (assign, nonatomic) BOOL isChallenge;//for subclasses


- (void)settitingSession:(QZBSession *)session bot:(id)bot;
- (void)initSession;

-(void)initSessionWithTopic:(QZBGameTopic *)topic user:(id<QZBUserProtocol>)user;
@property (weak, nonatomic) IBOutlet UIButton *playOfflineButton;

@end
