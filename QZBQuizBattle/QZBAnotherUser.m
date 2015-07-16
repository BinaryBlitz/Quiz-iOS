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
#import "QZBUserWorker.h"


@implementation QZBAnotherUser

//@synthesize name = _name;
//@synthesize userID = _userID;

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        
        if(![dict[@"username"] isEqual:[NSNull null]] && dict[@"username"] ){
            self.name = dict[@"username"];
        }else{
            self.name = @"";
        }
        
       // self.name = dict[@"name"];
        self.userID = (NSNumber *)dict[@"id"];
        
        self.userStatistics = [[QZBUserStatistic alloc] initWithDict:dict];
        
        NSString *avaURL = dict[@"avatar_thumb_url"];
        
        if(![avaURL isEqual:[NSNull null]] && avaURL ){
            NSString *urlStr = [QZBServerBaseUrl stringByAppendingString:avaURL];
            self.imageURL = [NSURL URLWithString:urlStr];
        } else{
            self.imageURL = nil;
        }
        
        NSString *avaURLBig = dict[@"avatar_url"];
        
        if(![avaURLBig isEqual:[NSNull null]] && avaURLBig ){
            NSString *urlStr = [QZBServerBaseUrl stringByAppendingString:avaURLBig];
            self.imageURLBig = [NSURL URLWithString:urlStr];
        } else{
            self.imageURLBig = nil;
        }
        
        
        
        
        if(![dict[@"viewed"] isEqual:[NSNull null]] && dict[@"viewed"]){
            BOOL viewed = [dict[@"viewed"] boolValue];
            self.isViewed = viewed;
        }else{
            self.isViewed = YES;
        }
        
        if(dict[@"is_online"] && ![dict[@"is_online"] isEqual:[NSNull null]]){
            self.isOnline = [dict[@"is_online"] boolValue];
        }
      //  QZBUserWorker *uw = [[QZBUserWorker alloc] init];
        
       // [QZBUserWorker saveUserInMemory:self];
        
        //NSArray *achievements = dict[@"achievements"];
        
        
        
        
    }
    return self;
}

@end
