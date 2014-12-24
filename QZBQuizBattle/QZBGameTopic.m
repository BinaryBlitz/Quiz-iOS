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

@end

@implementation QZBGameTopic

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
  self = [super init];
  if (self) {
    self.name = [dict objectForKey:@"name"];
  }
  return self;
}

@end
