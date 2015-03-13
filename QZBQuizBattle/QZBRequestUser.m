//
//  QZBRequestUser.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 12/03/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRequestUser.h"

@implementation QZBRequestUser

- (instancetype)initWithDictionary:(NSDictionary *)dict{
    self = [super initWithDictionary:dict];
    if(self){
        self.viewed = [dict[@"viewed"] boolValue];
    }
    return self;
}


@end
