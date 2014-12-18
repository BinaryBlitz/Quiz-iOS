//
//  QZBUser.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 13/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import "QZBUserInSession.h"
#import "QZBUser.h"

@implementation QZBUserInSession


- (instancetype)initWithUser:(QZBUser *)user
{
  self = [super init];
  if (self) {
    self.user = user;
    self.currentScore = 0;
    self.userAnswers = [NSMutableArray array];
  }
  return self;
}

@end
