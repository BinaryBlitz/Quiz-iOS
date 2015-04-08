//
//  QZBTopicChooserControllerViewController.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 24/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QZBUserProtocol.h"

@class QZBCategory;
@class QZBGameTopic;

@interface QZBTopicChooserControllerViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property(strong, nonatomic,readonly) QZBCategory *category;
@property (strong, nonatomic, readonly) NSArray *topics;
@property (strong, nonatomic) QZBGameTopic *choosedTopic;
@property (weak, nonatomic) IBOutlet UITableView *topicTableView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;


- (void)initTopicsWithCategory:(QZBCategory *)category;
- (void)initWithChallengeUser:(id<QZBUserProtocol>)user category:(QZBCategory *)category;

@end
