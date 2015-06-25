//
//  QZBRoomWorker.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 24/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRoomWorker.h"
#import "QZBRoom.h"
#import "QZBUserWithTopic.h"
#import "QZBServerManager.h"

@implementation QZBRoomWorker

+ (instancetype)sharedInstance {
    static QZBRoomWorker *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[QZBRoomWorker alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

//-(void)removeCurrentUserFromRoom:(QZBRoom *)room{
//    
//    [QZBServerManager sharedManager] DEL
//}


//-(void)leaveRoom:(QZBRoom *)room{
//    [QZBServerManager sharedManager] DELETELeaveRoomWithID:room.roomID onSuccess:^{
//        <#code#>
//    } onFailure:^(NSError *error, NSInteger statusCode) {
//        <#code#>
//    }
//    
//}
@end
