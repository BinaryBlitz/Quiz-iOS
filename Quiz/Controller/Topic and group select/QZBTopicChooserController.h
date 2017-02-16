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
@class DFImageView;

@interface QZBTopicChooserController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property(strong, nonatomic,readonly) QZBCategory *category;
@property (strong, nonatomic) NSArray *topics;
@property (strong, nonatomic) QZBGameTopic *choosedTopic;
@property (weak, nonatomic) IBOutlet UITableView *topicTableView;
//@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet DFImageView *backgroundImageView;

@property (strong, nonatomic) NSIndexPath *choosedIndexPath;

- (void)initTopicsWithCategory:(QZBCategory *)category;
- (void)initWithChallengeUser:(id<QZBUserProtocol>)user category:(QZBCategory *)category;

@end