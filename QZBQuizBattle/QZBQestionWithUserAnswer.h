//
//  QZBQestionWithAnswer.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 13/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import "QZBQuestion.h"
#import "QZBAnswer.h"

@interface QZBQestionWithUserAnswer : NSObject

@property (strong, nonatomic, readonly) QZBQuestion *qestion;
@property (strong, nonatomic, readonly) QZBAnswer *answer;


- (instancetype)initWithQestion:(QZBQuestion *)qestion answer:(QZBAnswer *)answer;

@end
