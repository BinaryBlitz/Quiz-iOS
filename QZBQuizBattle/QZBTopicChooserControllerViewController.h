//
//  QZBTopicChooserControllerViewController.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 24/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QZBCategory;
@interface QZBTopicChooserControllerViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *topicTableView;
//@property (strong, nonatomic) QZBCategory *category;

-(void)initTopicsWithCategory:(QZBCategory *)category;

@end
