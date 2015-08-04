//
//  QZBRoomInvite.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 16/07/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRoomInvite.h"

@interface QZBRoomInvite()

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *roomID;
@property (strong, nonatomic) NSNumber *roomInviteID;

@end

@implementation QZBRoomInvite

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        
//        if(dict[@"username"]) {
//            self.name = dict[@"username"];
//        } else {
//            self.name = nil;
//        }
        
        NSDictionary *creator = dict[@"creator"];
        self.name = creator[@"username"];
        
        //self.name = @"redo";
        self.roomID = dict[@"room_id"];
        self.roomInviteID = dict[@"id"];
    }
    return self;
}
//id = 33;
//"player_id" = 64;
//"room_id" = 168;
@end
