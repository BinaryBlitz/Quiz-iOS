//
//  QZBUserInRating.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 12/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBUserInRating.h"

@implementation QZBUserInRating

- (instancetype)initWithDictionary:(NSDictionary *)dict
{

    return [self initWithDictionary:dict position:0];
}
-(instancetype)initWithDictionary:(NSDictionary *)dict position:(NSInteger) position{
    self = [super init];
    if (self) {
        self.name = dict[@"name"];
        self.userID = [dict[@"id"] integerValue];
        self.points = [dict[@"points"] integerValue];
        self.position = position;
    }
    return self;

}

-(BOOL)isEqual:(id)object{
    
    if([object isKindOfClass:[self class]]){
        
        
        QZBUserInRating *obj = (QZBUserInRating *)object;
        if (self.userID == obj.userID){
            return YES;
    
        }
    }
    return NO;
    
    
}

-(NSUInteger)hash{
    
    return self.userID;
    
}



@end
