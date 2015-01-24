//
//  QZBCurrentUser.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 15/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBCurrentUser.h"
//#import "QZBUser.h"


@interface QZBCurrentUser()
@property (strong, nonatomic) QZBUser *user;
@end

@implementation QZBCurrentUser


+ (instancetype)sharedInstance
{
  static QZBCurrentUser *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[QZBCurrentUser alloc] init];
   
  });
  return sharedInstance;
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    
  }
  return self;
}

-(void)setUser:(QZBUser *)user{
  if(user){
    _user = user;
    
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:user];
                          
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"currentUser"];
    
  }
}

-(void)userLogOut{
    self.user = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"currentUser"];
}

-(BOOL)checkUser{
  
  if([[NSUserDefaults standardUserDefaults] objectForKey:@"currentUser"]){
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUser"];
    
    self.user = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    return YES;
    
  } else{
    return NO;
  }
  
}

@end
