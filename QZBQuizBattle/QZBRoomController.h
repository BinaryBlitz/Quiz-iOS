//
//  QZBRoomController.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 16/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QZBRoom;
@class QZBGameTopic;



@interface QZBRoomController : UITableViewController

- (void)initWithRoom:(QZBRoom *)room;

- (void)setCurrentUserTopic:(QZBGameTopic *)topic;

@end
