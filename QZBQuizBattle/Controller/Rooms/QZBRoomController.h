//
//  QZBRoomController.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 16/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QZBSettingTopicProtocol.h"

@class QZBRoom;
@class QZBGameTopic;

@interface QZBRoomController : UITableViewController<QZBSettingTopicProtocol>

- (void)initWithRoom:(QZBRoom *)room;

//- (void)setCurrentUserTopic:(QZBGameTopic *)topic;

-(void)setUserTopic:(QZBGameTopic *)topic;

@end
