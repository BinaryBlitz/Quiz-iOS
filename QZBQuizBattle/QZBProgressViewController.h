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
@class QZBChallengeDescription;
@class SVIndefiniteAnimatedView;

@interface QZBProgressViewController : UIViewController
@property (strong, nonatomic) QZBGameTopic *topic;

//@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelCrossButton;
@property (weak, nonatomic) IBOutlet UILabel *topicLabel;
@property (weak, nonatomic) IBOutlet UILabel *factLabel;
@property (assign, nonatomic) BOOL isChallenge;//for subclasses
@property (weak, nonatomic) IBOutlet SVIndefiniteAnimatedView *backView;
@property (strong, nonatomic) SVIndefiniteAnimatedView *animationView;

- (void)settitingSession:(QZBSession *)session bot:(id)bot;
- (void)initSession;
-(void)closeFinding;

-(void)initSessionWithTopic:(QZBGameTopic *)topic user:(id<QZBUserProtocol>)user;
-(void)initPlayAgainSessionWithTopic:(QZBGameTopic *)topic user:(id<QZBUserProtocol>)user;
-(void)initSessionWithDescription:(QZBChallengeDescription *)description;
@property (weak, nonatomic) IBOutlet UIButton *playOfflineButton;

@end
