//
//  QZBCategory.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 25/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import "QZBCategory.h"


@interface QZBCategory()

@property(copy, nonatomic) NSString *name;
@property(assign, nonatomic) NSInteger category_id;

@end

@implementation QZBCategory

- (instancetype)initWithDict:(NSDictionary *)dict
{
  self = [super init];
  if (self) {
    self.name = [dict objectForKey:@"name"];
    self.category_id = [[dict objectForKey:@"id"] integerValue];
  }
  return self;
}


@end
