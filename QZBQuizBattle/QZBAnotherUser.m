//
//  QZBAnotherUser.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 12/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBAnotherUser.h"
#import "QZBServerManager.h"
#import "QZBUserStatistic.h"
#import "QZBAchievement.h"

@implementation QZBAnotherUser

//@synthesize name = _name;
//@synthesize userID = _userID;

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.name = dict[@"name"];
        self.userID = (NSNumber *)dict[@"id"];
        
        NSString *avaURL = dict[@"avatar_url"];
        
        self.userStatistics = [[QZBUserStatistic alloc] initWithDict:dict];
        
        if(![avaURL isEqual:[NSNull null]] && avaURL ){
            NSString *urlStr = [QZBServerBaseUrl stringByAppendingString:avaURL];
            NSLog(@"ava url %@", urlStr);
            self.imageURL = [NSURL URLWithString:urlStr];
        } else{
            self.imageURL = nil;
        }
        
        //NSArray *achievements = dict[@"achievements"];
        
        
        
        
    }
    return self;
}

@end
