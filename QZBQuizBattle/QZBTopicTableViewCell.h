//
//  QZBTopicTableViewCell.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 24/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UAProgressView.h> 

@interface QZBTopicTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *topicName;
@property (weak, nonatomic) IBOutlet UAProgressView *topicProgressView;

-(void)initCircularProgressWithLevel:(NSInteger)level progress:(float)progress;

@end
