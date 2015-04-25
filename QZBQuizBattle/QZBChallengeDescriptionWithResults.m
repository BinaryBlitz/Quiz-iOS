//
//  QZBChallengeDescriptionWithResults.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 24/04/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBChallengeDescriptionWithResults.h"
#import "QZBAnotherUser.h"
#import "QZBUser.h"
#import "QZBCurrentUser.h"
#import "QZBGameTopic.h"
#import "CoreData+MagicalRecord.h"


@interface QZBChallengeDescriptionWithResults()

@property(assign, nonatomic) NSInteger firstResult;
@property(assign, nonatomic) NSInteger opponentResult;
@property(strong, nonatomic) QZBAnotherUser *opponentUser;
@property(strong, nonatomic) QZBUser *firstUser;
@property(assign, nonatomic) NSInteger multiplier;



@end

@implementation QZBChallengeDescriptionWithResults

- (instancetype)initWithDictionary:(NSDictionary *)dict{
    
    self = [super initWithDictionary:dict];
    
    if(self){
        NSDictionary *resultDict = dict[@"results"];
        NSDictionary *firstDict = resultDict[@"host"];
        NSDictionary *opponentDict = resultDict[@"opponent"];
        
        self.firstResult = [self pointsFromDict:firstDict];
        self.opponentResult = [self pointsFromDict:opponentDict];
        self.opponentUser = [[QZBAnotherUser alloc] initWithDictionary:opponentDict];
        self.firstUser = [QZBCurrentUser sharedInstance].user;
        self.multiplier = [firstDict[@"multiplier"] integerValue];
        
       // NSNumber *topicID = dict[@"topic_id"];
        
        
        
        
        
        
    }
    return self;

}

-(NSInteger)pointsFromDict:(NSDictionary *)dict{
    return [dict[@"points"] integerValue];
}

//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//        <#statements#>
//    }
//    return self;
//}

@end
