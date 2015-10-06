//
//  QZBRoomInvite.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 16/07/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QZBRoomInvite : NSObject

@property (strong, nonatomic, readonly) NSString *name;
@property (strong, nonatomic, readonly) NSNumber *roomID;
@property (strong, nonatomic, readonly) NSNumber *roomInviteID;
@property (strong, nonatomic, readonly) NSDate *createdAt;


- (instancetype)initWithDictionary:(NSDictionary *)dict;
@end
