//
//  QZBMainGameScreenTVC.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 18/03/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QZBTopicChooserController.h"

@interface QZBMainGameScreenTVC : QZBTopicChooserController
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
-(void)reloadTopicsData;

@end
