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

//@property(strong, nonatomic) QZBRoom *room;
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(oneOfUsersFinishedGame:)
                                                     name:QZBOneUserFinishedGameInRoom
                                                   object:nil];
       // [NSNotificationCenter defaultCenter] addObserver:self selector:<#(SEL)#> name:<#(NSString *)#> object:<#(id)#>
    }
}

- (void)closeOnlineWorker {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.onlineWorker closeConnection];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)userWithId:(NSNumber *)userID reachedPoints:(NSNumber *)points {
    QZBUserWithTopic *userWithTopic = [self userWithTopicWithID:userID];
    
    for(QZBUserWithTopic *uandt in self.room.participants) {
        if([uandt.user.userID isEqualToNumber:userID]){
            userWithTopic = uandt;
            break;
        }
    }
    
    if(userWithTopic){
        [userWithTopic addReachedPoints:points];
    }
}

-(void)userWithId:(NSNumber *)userID resultPoints:(NSNumber *)points {
    QZBUserWithTopic *userWithTopic = [self userWithTopicWithID:userID];
    
    if(userWithTopic){
        [userWithTopic setPoints:points];
        userWithTopic.finished = YES;
    }
    
}


-(QZBUserWithTopic *)userWithTopicWithID:(NSNumber *)userID {
   // QZBUserWithTopic *userWithTopic = nil;
    
    for(QZBUserWithTopic *uandt in self.room.participants) {
        if([uandt.user.userID isEqualToNumber:userID]){
            //userWithTopic = uandt;
            return uandt;
            //break;
        }
    }
    return nil;
    
}

#pragma mark - notifications

- (void)oneOfUsersFinishedGame:(NSNotification *)note{
    if(note && [note.name isEqualToString:QZBOneUserFinishedGameInRoom]) {
        NSDictionary *d = note.object;
        
        NSNumber *userID = d[@"player_id"];
        NSNumber *points = d[@"points"];
        
        [self userWithId:userID resultPoints:points];
    //    [self.tableView reloadData];
    }
}

//-(void)nlineWorker:(QZBRoomOnlineWorker *)onlineWorker


@end
