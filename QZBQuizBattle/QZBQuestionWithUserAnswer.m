//
//  QZBQestionWithAnswer.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 13/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import "QZBQuestionWithUserAnswer.h"

@interface QZBQuestionWithUserAnswer()

@property (strong, nonatomic) QZBQuestion *question;
@property (strong, nonatomic) QZBAnswer *answer;



@end

@implementation QZBQuestionWithUserAnswer

- (instancetype)initWithQestion:(QZBQuestion *)qestion answer:(QZBAnswer *)answer
{
  self = [super init];
  if (self) {
    self.question = qestion;
    self.answer = answer;
    
  }
  return self;
}

@end
