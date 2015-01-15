//
//  QZBCurrentUser.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 15/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QZBUser;
@interface QZBCurrentUser : NSObject

+ (instancetype)sharedInstance;
-(void)setUser:(QZBUser *)user;

@end
