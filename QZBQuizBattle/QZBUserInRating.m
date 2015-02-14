//
//  QZBUserInRating.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 12/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBUserInRating.h"

@implementation QZBUserInRating

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.name = dict[@"name"];
        self.userID = [dict[@"id"] integerValue];
        self.points = [dict[@"points"] integerValue];
    }
    return self;
}

@end
