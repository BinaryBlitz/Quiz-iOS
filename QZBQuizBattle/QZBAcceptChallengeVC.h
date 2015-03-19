//
//  QZBAcceptChallengeVC.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 17/03/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QZBProgressViewController.h"
#import "QZBUserProtocol.h"


@interface QZBAcceptChallengeVC : QZBProgressViewController

-(void)initWithLobbyID:(NSNumber *)lobbyID user:(id<QZBUserProtocol>)user;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;

@property (weak, nonatomic) IBOutlet UIButton *declineButton;

@end
