//
//  QZBFriendRequest.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 21/05/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QZBAnotherUser.h"

@interface QZBFriendRequest : QZBAnotherUser

@property(strong, nonatomic, readonly) NSNumber *requestID;

@end
