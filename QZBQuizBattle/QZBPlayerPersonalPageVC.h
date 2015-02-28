//
//  QZBPlayerPersonalPageVC.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 21/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QZBUserProtocol.h"

@interface QZBPlayerPersonalPageVC : UITableViewController

@property (strong, nonatomic) IBOutlet UITableView *playerTableView;

-(void)initPlayerPageWithUser:(id<QZBUserProtocol>)user;
@property (weak, nonatomic) IBOutlet UIButton *multiUseButton;

@end
