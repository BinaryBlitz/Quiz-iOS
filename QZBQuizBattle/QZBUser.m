//
//  QZBUser.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 13/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import "QZBUser.h"

@interface QZBUser ()

@property(assign, nonatomic) NSInteger user_id;

@end

@implementation QZBUser

- (instancetype)initWithUserId:(NSInteger)user_id name:(NSString *) name userpicURL:(NSURL *)url
{
  self = [super init];
  if (self) {
    self.user_id = user_id;
  }
  return self;
}


//REDO
-(instancetype)initWithId:(NSInteger)user_id{
  
  NSURL *url = [NSURL URLWithString:@""];
  
  return [self initWithUserId:user_id name:@"" userpicURL:url];
  
}

@end
