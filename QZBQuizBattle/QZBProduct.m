//
//  QZBProduct.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 14/03/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBProduct.h"

@interface QZBProduct()

@property (copy, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSNumber *topicID;
@property (assign, nonatomic) BOOL isPurchased;

@end

@implementation QZBProduct

- (instancetype)initWhithDictionary:(NSDictionary *) dict
{
    self = [super init];
    if (self) {
//        "identifier": "booster-x3",
//        "topic_id": null,
//        "purchased": true
        
        self.identifier = dict[@"identifier"];
        self.topicID = dict[@"topic_id"];
        self.isPurchased = [dict[@"purchased"] boolValue];
        
    }
    return self;
}


@end
