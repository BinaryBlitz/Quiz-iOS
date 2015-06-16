//
//  QZBRoom.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 16/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRoom.h"
#import "QZBAnotherUser.h"


@interface QZBRoom ()

@property(strong, nonatomic) NSNumber *roomID;
@property(strong, nonatomic) QZBAnotherUser *owner;
@property(strong, nonatomic) NSDate *creationDate;

@end

@implementation QZBRoom

- (instancetype)initWithDictionary:(NSDictionary *)d
{
    self = [super init];
    if (self) {
        self.roomID = d[@"id"];
        
    }
    return self;
}

@end
