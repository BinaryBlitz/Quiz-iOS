//
//  QZBCreateRoomController.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 29/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QZBSettingTopicProtocol.h"

@interface QZBCreateRoomController : UITableViewController<QZBSettingTopicProtocol>

-(void)setUserTopic:(QZBGameTopic*)topic;

@end
