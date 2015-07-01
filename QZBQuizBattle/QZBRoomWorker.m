//
//  QZBRoomWorker.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 24/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRoomWorker.h"
#import "QZBRoom.h"
#import "QZBRoomOnlineWorker.h"
#import "QZBUserWithTopic.h"
#import "QZBServerManager.h"

@interface QZBRoomWorker ()

@property(strong, nonatomic) QZBRoom *room;
@property(strong, nonatomic) QZBRoomOnlineWorker *onlineWorker;

@end

@implementation QZBRoomWorker


- (instancetype)initWithRoom:(QZBRoom *)room {
    self = [super init];
    if (self) {
        self.room = room;
    }
    return self;
}

-(void)addRoomOnlineWorker {
    if(!self.onlineWorker){
        self.onlineWorker = [[QZBRoomOnlineWorker alloc] initWithRoom:self.room];
    }
}

//-(void)nlineWorker:(QZBRoomOnlineWorker *)onlineWorker


@end
