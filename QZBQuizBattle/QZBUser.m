//
//  QZBUser.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 13/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import "QZBUser.h"

@interface QZBUser ()

//@property(assign, nonatomic) NSInteger user_id;
@property(copy, nonatomic) NSString *name;
@property(copy, nonatomic) NSString *email;
@property(copy, nonatomic) NSString *api_key;

@end

@implementation QZBUser
/*
- (instancetype)initWithUserId:(NSInteger)user_id name:(NSString *) name userpicURL:(NSURL *)url
{
  self = [super init];
  if (self) {
    self.user_id = user_id;
  }
  return self;
}*/


//REDO
/*
-(instancetype)initWithId:(NSInteger)user_id{
  
  NSURL *url = [NSURL URLWithString:@""];
  
  return [self initWithUserId:user_id name:@"" userpicURL:url];
  
}*/

- (instancetype)initWithDict:(NSDictionary *)dict
{
  self = [super init];
  if (self) {
    self.api_key = [dict objectForKey:@"api_key"];
    self.name = [dict objectForKey:@"name"];
    self.email = [dict objectForKey:@"email"];
    
  }
  return self;
}


- (instancetype)initWithCoder:(NSCoder *)coder
{
  self = [[QZBUser alloc] init];
  if (self) {
    
    self.name = [coder decodeObjectForKey:@"userName"];
    self.email = [coder decodeObjectForKey:@"userEmail"];
    self.api_key = [coder decodeObjectForKey:@"userApiKey"];
    
    
  }
  return self;
}

-(void)encodeWithCoder:(NSCoder *)coder{
  
  [coder encodeObject:self.name forKey:@"userName"];
  [coder encodeObject:self.email forKey:@"userEmail"];
  [coder encodeObject:self.api_key forKey:@"userApiKey"];
  
}


@end
