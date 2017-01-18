//
//  QZBNewQuestionController.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 13/09/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QZBSettingTopicProtocol.h"

@interface QZBNewQuestionController : UITableViewController <QZBSettingTopicProtocol>
//@property (weak, nonatomic) IBOutlet UITextView *inputTextView;
//@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *answersTextFields;

-(void)setUserTopic:(QZBGameTopic *)topic;

@end
