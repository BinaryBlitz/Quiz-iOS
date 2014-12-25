//
//  QZBAnswer.h
//  QZBQuizBattle
//
// Ответ ползователя на вопрос и время ответа на вопрос
//
//  Created by Andrey Mikhaylov on 13/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QZBAnswer : NSObject

@property( assign, nonatomic,readonly) NSUInteger answerNum;
@property(assign, nonatomic, readonly) NSUInteger time;
@property(copy, nonatomic, readonly) NSString *answer;
@property(assign, nonatomic, readonly) NSInteger *answerId;

- (instancetype)initWithAnswerNumber:(NSUInteger) answerNum answerTime:(NSUInteger)time;

@end
