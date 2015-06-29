//
//  QZBRoomResultTVC.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 25/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QZBRoom;

@interface QZBRoomResultTVC : UITableViewController


- (void)configureResultWithRoom:(QZBRoom *)room;

@end
