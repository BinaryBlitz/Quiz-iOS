//
//  QZBUserInRating.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 12/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBAnotherUser.h"
#import "QZBUserProtocol.h"

@interface QZBUserInRating : QZBAnotherUser<QZBUserProtocol>

@property(assign, nonatomic) NSInteger points;
@property(assign, nonatomic) NSInteger position;

- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict position:(NSInteger) position;

@end
