//
//  QZBUserInRating.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 12/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBAnotherUser.h"

@interface QZBUserInRating : QZBAnotherUser

@property(assign, nonatomic) NSInteger points;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
