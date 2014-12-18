//
//  QZBQestionWithAnswer.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 13/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import "QZBQestionWithUserAnswer.h"

@interface QZBQestionWithUserAnswer()

@property (strong, nonatomic) QZBQuestion *qestion;
@property (strong, nonatomic) QZBAnswer *answer;



@end

@implementation QZBQestionWithUserAnswer

- (instancetype)initWithQestion:(QZBQuestion *)qestion answer:(QZBAnswer *)answer
{
  self = [super init];
  if (self) {
    self.qestion = qestion;
    self.answer = answer;
    
  }
  return self;
}

@end
