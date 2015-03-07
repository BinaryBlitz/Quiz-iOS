//
//  QZBAnotherUser.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 12/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QZBUserProtocol.h"

@interface QZBAnotherUser : NSObject<QZBUserProtocol>

@property(strong, nonatomic) NSNumber *userID;
@property(copy, nonatomic) NSString *name;
@property(assign, nonatomic) BOOL isFriend;

- (instancetype)initWithDictionary:(NSDictionary *)dict;


@end
