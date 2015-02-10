//
//  QZBCategoryChooserVC.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 15/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QZBCategoryChooserVC : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;

@end
