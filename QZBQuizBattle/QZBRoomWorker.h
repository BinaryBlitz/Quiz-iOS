//
//  QZBRoomWorker.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 24/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QZBRoom;

@interface QZBRoomWorker : NSObject

- (instancetype)initWithRoom:(QZBRoom *)room;
- (void)addRoomOnlineWorker;

@end
