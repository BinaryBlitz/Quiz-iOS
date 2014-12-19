//
//  QZBQestionWithAnswer.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 13/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import "QZBQuestion.h"
#import "QZBAnswer.h"

@interface QZBQuestionWithUserAnswer : NSObject

@property (strong, nonatomic, readonly) QZBQuestion *question;
@property (strong, nonatomic, readonly) QZBAnswer *answer;


- (instancetype)initWithQestion:(QZBQuestion *)qestion answer:(QZBAnswer *)answer;

@end
