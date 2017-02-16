//
//  QZBQuestionReportButtonCell.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 29/08/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QZBQuestionReportButtonCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *reportButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *reportActivityIndicator;

@end
