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

@property(nonatomic, assign, readonly) NSUInteger answerNum;
@property(nonatomic, assign, readonly) NSUInteger time;

- (instancetype)initWithAnswerNumber:(NSUInteger) answerNum answerTime:(NSUInteger)time;

@end
