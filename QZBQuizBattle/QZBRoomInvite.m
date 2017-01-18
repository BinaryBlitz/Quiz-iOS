//
//  QZBRoomInvite.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 16/07/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRoomInvite.h"
#import "NSDate+QZBDateCategory.h"

@interface QZBRoomInvite()

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *roomID;
@property (strong, nonatomic) NSNumber *roomInviteID;
@property (strong, nonatomic) NSDate *createdAt;

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
        
        if(dict[@"created_at"] && ![dict[@"created_at"] isEqual:[NSNull null]]) {
            self.createdAt = [NSDate customDateFromString:dict[@"created_at"]];//[NSDate date];//redo!
        }
    }
    return self;
}
//id = 33;
//"player_id" = 64;
//"room_id" = 168;
@end
