//
//  QZBResultOfSessionCell.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 25/04/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QZBResultOfSessionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *topicNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *opponentNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *declineButton;

@property (weak, nonatomic) IBOutlet UIView *underView;
@property (weak, nonatomic) IBOutlet UIView *backView;

@end
