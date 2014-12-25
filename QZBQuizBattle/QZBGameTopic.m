//
//  QZBGameTopic.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 24/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import "QZBGameTopic.h"

@interface QZBGameTopic()
@property(copy, nonatomic) NSString *name;
@property(assign, nonatomic) NSInteger topic_id;

@end

@implementation QZBGameTopic

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
  self = [super init];
  if (self) {
    self.name = [dict objectForKey:@"name"];
    self.topic_id = [[dict objectForKey:@"id"] integerValue];
  }
  return self;
}

@end
