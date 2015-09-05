//
//  QZBQuestionReportTVC.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 28/08/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QZBGameTopic;
@interface QZBQuestionReportTVC : UITableViewController

- (void)configureWithQuestions:(NSArray *)questions topic:(QZBGameTopic *)topic;

@end
