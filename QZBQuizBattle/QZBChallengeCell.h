//
//  QZBChallengeCell.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 18/03/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QZBChallengeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *topicNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *opponentNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *declineButton;

@end
