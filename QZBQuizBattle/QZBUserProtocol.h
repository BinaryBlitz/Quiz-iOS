//
//  QZBUserProtocol.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 28/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//


//Protocol for all users in program
#import <Foundation/Foundation.h>
#import "QZBUserStatistic.h"

@protocol QZBUserProtocol <NSObject>

@required

-(NSString *)name;

-(NSNumber *)userID;

-(NSURL *)imageURL;

@optional

-(BOOL)isFriend;

-(QZBUserStatistic *)userStatistics;

@end
