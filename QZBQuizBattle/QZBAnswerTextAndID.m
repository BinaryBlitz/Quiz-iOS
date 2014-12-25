//
//  QZBAnswerTextAndID.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 25/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import "QZBAnswerTextAndID.h"

@interface QZBAnswerTextAndID()

@property(copy,   nonatomic) NSString *answerText;
@property(assign, nonatomic) NSInteger answerID;

@end

@implementation QZBAnswerTextAndID


- (instancetype)initWithText:(NSString *)answer answerID:(NSInteger)answerID
{
  self = [super init];
  if (self) {
    self.answerText = answer;
    self.answerID = answerID;
  }
  return self;
}

@end
