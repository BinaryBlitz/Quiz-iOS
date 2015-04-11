//
//  QZBEndGameVC.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 09/04/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QZBEndGameVC : UIViewController<UITableViewDataSource,
UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end
