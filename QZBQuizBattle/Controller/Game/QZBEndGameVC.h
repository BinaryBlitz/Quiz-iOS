//
//  QZBEndGameVC.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 09/04/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QZBChallengeDescriptionWithResults;
@interface QZBEndGameVC : UITableViewController
//@property (weak, nonatomic) IBOutlet UITableView *tableView;
//@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

-(void)initWithChallengeResult:(QZBChallengeDescriptionWithResults *)challengeDescription;

@end
